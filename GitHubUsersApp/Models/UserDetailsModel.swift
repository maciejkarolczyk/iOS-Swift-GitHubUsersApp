import Foundation
import RealmSwift

class UserDetails:Object, Decodable{
    @objc dynamic var id: Int = 0
    @objc dynamic var login : String? = ""
    @objc dynamic var avatarUrl : String? = ""
    @objc dynamic var htmlUrl : String? = ""
    @objc dynamic var type : String? = ""
    @objc dynamic var name : String? = ""
    @objc dynamic var company : String? = ""
    @objc dynamic var location : String? = ""
    @objc dynamic var email : String? = ""
    @objc dynamic var publicReposCount : Int = 0
    @objc dynamic var followersCount : Int = 0
    @objc dynamic var creationDate : Date? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
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
