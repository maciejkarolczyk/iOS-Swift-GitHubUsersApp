import UIKit
import RealmSwift

class DBManager {
    
    static let sharedInstance = DBManager()
    
    private init() {}
    
    func saveObjectToRealm<T:Object>(_ realmObject:T) -> ThreadSafeReference<T>  {
        let realm = try! Realm()
        try! realm.write {
            realm.add(realmObject, update: .modified)
        }
        let objectReference = ThreadSafeReference(to: realmObject)
        return objectReference
    }
    
    func getCachedUserDetails(userLogin:String) -> ThreadSafeReference<UserDetails>? {
        let matchingUsersResult = self.getObjectsFromRealm(ofType: UserDetails.self, withFilter: "login LIKE '\(userLogin)'")
        
        if matchingUsersResult.count > 0 {
            if let savedUser = matchingUsersResult.first {
                let objectReference = ThreadSafeReference(to: savedUser)
                return objectReference
            }
        }
        return nil
    }
    
    func getObjectsFromRealm<T:Object>(ofType: T.Type, withFilter: String) -> Results<T> {
        let realm = try! Realm()
        let resultObjects = realm.objects(T.self).filter(withFilter)

        return resultObjects
    }
}
