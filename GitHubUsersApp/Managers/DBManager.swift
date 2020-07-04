import UIKit
import RealmSwift

class DBManager {
    
    static let sharedInstance = DBManager()
    
    private init() {}
    
    func appendToRealmModel(_ realmObject:UsersModel) {
        let realm = try! Realm()
        let usersModel = realm.objects(UsersModel.self).filter("queryUsed = '\(realmObject.queryUsed)'").first!
        for object in realmObject.users {
            if realm.object(ofType: UserTableModel.self, forPrimaryKey: object.name) == nil {
                try! realm.write {
                    usersModel.users.append(object)
                }
            }
        }
    }
    
    func saveObjectToRealm<T:Object>(_ realmObject:T) -> ThreadSafeReference<T> {
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
    
    func getCachedUsersModel(queryUsed:String) -> ThreadSafeReference<UsersModel>? {
        let matchingUsersResult = self.getObjectsFromRealm(ofType: UsersModel.self, withFilter: "queryUsed LIKE '\(queryUsed)'")
        
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
    
    func resolveThreadSafeReference<T:Object>(reference: ThreadSafeReference<T>) -> T? {
        let realm = try! Realm()
        guard let model = realm.resolve(reference) else {return nil}
        return model
    }
}
