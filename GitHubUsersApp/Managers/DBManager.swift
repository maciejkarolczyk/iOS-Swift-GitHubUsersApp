import UIKit
import RealmSwift

class DBManager {
    
    private var database:Realm
    static let sharedInstance = DBManager()
    
    private init() {
        database = try! Realm()
    }
    
    func getDataFromDB() -> Results<UserDetails> {
        let results: Results<UserDetails> = database.objects(UserDetails.self)
        return results
    }
    
    func addData(object: UserDetails) {
        try! database.write {
            
            database.add(object, update:.modified)
            print("Added new object")
        }
    }
    func deleteAllFromDatabase() {
        try!   database.write {
            database.deleteAll()
        }
    }
    func deleteFromDb(object: UserDetails) {
        try!   database.write {
            database.delete(object)
        }
    }
}
