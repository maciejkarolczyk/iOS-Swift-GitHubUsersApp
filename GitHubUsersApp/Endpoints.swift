import Foundation

struct Endpoints {
    static let usersEndpoint = "https://api.github.com/search/users"
    static let usersDetailsEndpoint = "https://api.github.com/users/"
    
    static func getUsersEndpoint() -> String {
        return usersEndpoint
    }
    
    static func getUsersDetailsEndpoint(userName: String) -> String {
        var currentEndpoint = usersDetailsEndpoint
        currentEndpoint += userName
        return currentEndpoint
    }
}
