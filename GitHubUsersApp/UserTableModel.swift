import Foundation


struct UsersModel:Decodable {
    var users: [UserTableModel]
    
    enum CodingKeys: String, CodingKey {
        case users = "items"
    }
    
    func count() -> Int {
        return users.count
    }
}

struct UserTableModel:Decodable {
    let name: String
    let score: Int
    let avatarUrl : String
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case score
        case avatarUrl = "avatar_url"
    }
}
