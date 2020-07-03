import Foundation
import Alamofire
import RealmSwift

class ServiceManager {
    
    static let sharedInstance = ServiceManager()
    
    private init() {}
    
    func requestUsers(query:String?, page:Int = 1, _ completion: @escaping (UsersModel) -> Void, failure: @escaping (String) -> Void) {
        //wrong practice. Apple discourages from checking connectivity before request. Instead, one should send the request and listen to error
        if InternetConnectionManager.isConnectedToNetwork() {
            let parameters: [String:String?] = ["q" : query,
                                                "per_page": "30",
                                                "page":String(page)]
            
            let queue = DispatchQueue(label: "usersQueue", qos: .background, attributes: .concurrent)
            
            AF.request(Endpoints.getUsersEndpoint(), method: .get, parameters: parameters).validate().responseDecodable(of:UsersModel.self, queue:queue) { response in
                if let error = response.error {
                    if let data = response.data, let errorString = String(bytes: data, encoding: .utf8) {
                        failure(errorString)
                    } else {
                        failure(error.localizedDescription)
                    }
                }
                guard let users = response.value else { return }
                completion(users)
            }
        } else {
            failure("not connected to internet")
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
                failure("not connected to internet and user is not cached")
            }
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
