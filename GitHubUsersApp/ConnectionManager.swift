import Foundation
import Alamofire
import RealmSwift

class ConnectionManager {
    
    static func requestUsers(query:String?, page:Int = 1, _ completion: @escaping (UsersModel) -> Void, failure: @escaping (String) -> Void) {
        //wrong practice. Apple discourages from checking connectivity before request. Instead, one should
        if InternetConnectionManager.isConnectedToNetwork() {
            let parameters: [String:String?] = ["q" : query,
                                                "per_page": "30",
                                                "page":String(page)]
            
            let queue = DispatchQueue(label: "usersQueue", qos: .background, attributes: .concurrent)
            
            AF.request(Endpoints.getUsersEndpoint(), method: .get, parameters: parameters).responseDecodable(of:UsersModel.self, queue:queue) { response in
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
    
    static func requestUserDetails(userName:String?, _ completion: @escaping (UserDetails) -> Void, failure: @escaping (String) -> Void) {
        if let userName = userName {
            if InternetConnectionManager.isConnectedToNetwork() {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let queue = DispatchQueue(label: "usersDetailsQueue", qos: .background, attributes: .concurrent)
                AF.request(Endpoints.getUsersDetailsEndpoint(userName: userName), method: .get).responseDecodable(of:UserDetails.self, queue:queue, decoder:decoder) { response in
                    if let error = response.error {
                        if let data = response.data, let errorString = String(bytes: data, encoding: .utf8) {
                            failure(errorString)
                        } else {
                            failure(error.localizedDescription)
                        }
                    }
                    guard let userDetails = response.value else { return }
                    completion(userDetails)
                }
            } else {
                failure("not connected to internet")
            }
        }
    }
    
}
