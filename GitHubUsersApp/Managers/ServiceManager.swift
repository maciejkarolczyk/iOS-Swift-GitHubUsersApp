import Foundation
import Alamofire
import RealmSwift

class ServiceManager {
    
    static let sharedInstance = ServiceManager()
    
    private init() {}
    
    func requestUsersAfterSearch(query:String, page:Int = 1, _ completion: @escaping (ThreadSafeReference<UsersModel>) -> Void, failure: @escaping (String) -> Void) {
        
        //wrong practice. Apple discourages from checking connectivity before request. Instead, one should send the request and listen to error
        if InternetConnectionManager.isConnectedToNetwork() {
            let parameters = Constants.getUsersRequestParametes(query:query,page: page)
            
            let queue = DispatchQueue(label: "usersQueue", qos: .background, attributes: .concurrent)
            
            AF.request(Constants.getUsersEndpoint(), method: .get, parameters: parameters).validate().responseDecodable(of:UsersModel.self, queue:queue) { response in
                if response.error != nil {
                    self.handleDownloadError(response: response, failureBlock: failure)
                }
                guard let users = response.value else { return }
                users.queryUsed = query
                let threadSafeReference = DBManager.sharedInstance.saveObjectToRealm(users)
                completion(threadSafeReference)
            }
        } else if let cachedModel = DBManager.sharedInstance.getCachedUsersModel(queryUsed: query) {
            //check if user exist in realm
            completion(cachedModel)
            return
        } else {
            failure(Strings.noInternet)
        }
    }
    
    func requestUserDetails(userName:String?, _ completion: @escaping (ThreadSafeReference<UserDetails>) -> Void, failure: @escaping (String) -> Void) {
        
            //check if user exist in realm
        if let userName = userName {
            if let cachedUser = DBManager.sharedInstance.getCachedUserDetails(userLogin: userName) {
                completion(cachedUser)
                return
            }
                //wrong practice. Apple discourages from checking connectivity before request. Instead, one should send the request and listen to error
            if InternetConnectionManager.isConnectedToNetwork() {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let queue = DispatchQueue(label: "usersDetailsQueue", qos: .background, attributes: .concurrent)
                AF.request(Constants.getUsersDetailsEndpoint(userName: userName), method: .get).validate().responseDecodable(of:UserDetails.self, queue:queue, decoder:decoder) { response in
                    if response.error != nil {
                        self.handleDownloadError(response: response, failureBlock: failure)
                    }
                    guard let userDetails = response.value else { return }
                    
                    let threadSafeReference = DBManager.sharedInstance.saveObjectToRealm(userDetails)
                    completion(threadSafeReference)
                }
            } else {
                failure(Strings.noInternetAndCache)
            }
        }
    }
    
    func downloadMoreUsers(query:String, page:Int = 1, completion: @escaping () -> Void, failure: @escaping (String) -> Void) {
        
        //wrong practice. Apple discourages from checking connectivity before request. Instead, one should send the request and listen to error
        let parameters = Constants.getUsersRequestParametes(query:query,page: page)
        
        let queue = DispatchQueue(label: "usersQueue", qos: .background, attributes: .concurrent)
        
        AF.request(Constants.getUsersEndpoint(), method: .get, parameters: parameters).validate().responseDecodable(of:UsersModel.self, queue:queue) { response in
            if response.error != nil {
                self.handleDownloadError(response: response, failureBlock: failure)
            }
            guard let users = response.value else { return }
            users.queryUsed = query
            DBManager.sharedInstance.appendToRealmModel(users)
            completion()
        }
    }
    
    func handleDownloadError<T:Object>(response: DataResponse<T, AFError>, failureBlock:(String) -> Void) {
        guard let error = response.error else {return}
        if let data = response.data, let errorString = String(bytes: data, encoding: .utf8) {
            failureBlock(errorString)
        } else {
            failureBlock(error.localizedDescription)
        }
    }
}
