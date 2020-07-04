import Foundation
import RealmSwift


class UsersModel:Object, Decodable {
    var users = List<UserTableModel>()
    @objc dynamic var queryUsed: String = ""
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subModels = try container.decode([UserTableModel].self, forKey: .users)
        users.append(objectsIn: subModels)
    }
    
    override static func primaryKey() -> String? {
        return "queryUsed"
    }
    
    enum CodingKeys: String, CodingKey {
        case users = "items"
    }
    
    func count() -> Int {
        return users.count
    }
}

class UserTableModel:Object, Decodable {
    @objc dynamic var name: String = ""
    @objc dynamic var score: Int = 0
    @objc dynamic var avatarUrl : String = ""
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case score
        case avatarUrl = "avatar_url"
    }
}
