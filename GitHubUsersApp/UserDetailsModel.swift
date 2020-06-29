import Foundation
import RealmSwift

class UserDetails:Object, Decodable {
    let id: Int
    let avatarUrl : String?
    let htmlUrl : String?
    let type : String?
    let name : String?
    let company : String?
    let location : String?
    let email : String?
    let publicReposCount : Int?
    let followersCount : Int?
    let creationDate : Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case type
        case name
        case company
        case location
        case email
        case publicReposCount = "public_repos"
        case followersCount = "followers"
        case creationDate = "created_at"
    }
}
