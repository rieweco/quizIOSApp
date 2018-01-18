import Foundation
import CoreData

class UserPersistence {
	let coreDataManager: CoreDataManager
	
	init(coreDataManager: CoreDataManager) {
		self.coreDataManager = coreDataManager
	}
    
    func insertUserInfo(with userInfo: UserInfo, complete:(() -> Void)?){
        
        let managedContext = coreDataManager.persistentContainer.viewContext
            do {
                var user = self.getUser(with: userInfo.userId, context: managedContext)
                guard let _ = user else {
                    user = User(context: managedContext)
                    try user?.populate(from: userInfo)
                     try managedContext.save()
                    return
                }
                managedContext.delete(user!)
                user = User(context: managedContext)
                try user?.populate(from: userInfo)
                try managedContext.save()
                Log.info("persistUserData")
                
            } catch let error as NSError {
                print(error)
            }
            complete?()
    }
    
    func getUser() -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let results = try coreDataManager.persistentContainer.viewContext.fetch(request)
            if let user = results.first{
                Log.info(user)
                var userInfo: UserInfo?
                do{
                    try userInfo?.populate(from: user)
                    Log.info(userInfo)
                }catch{
                    Log.error(error)
                }

                if let userId = user.userId{
                    Log.info(userId)
                }
            }
            return results.first
        } catch {
            return nil
        }
    }
    
    func updateUserStatus(with id: String, with status: String) -> Bool?{
        let managedContext = coreDataManager.persistentContainer.viewContext
        do {
            guard let updateUser = self.getUser(with: id, context: managedContext)
                else{
                    Log.info("No user existed with that id")
                    return false
            }
            updateUser.status = status
            try managedContext.save()
        } catch let error as NSError {
            Log.info(error)

        }
        return true
    }
    
    func updateUserStatusIfIsLeader(with id: String, with isLeader: Bool) -> Bool?{
        let managedContext = coreDataManager.persistentContainer.viewContext
        do {
            guard let updateUser = self.getUser(with: id, context: managedContext)
                else{
                    Log.info("No user existed with that id")
                    return false
            }
            updateUser.isLeader = isLeader
            try managedContext.save()
        } catch let error as NSError {
            Log.info(error)
            
        }
        return true
    }
    
    func updateUserGroupId(with id: String, with groupId: String) -> Bool?{
        let managedContext = coreDataManager.persistentContainer.viewContext
        do {
            guard let updateUser = self.getUser(with: id, context: managedContext)
                else{
                    Log.info("No user existed with that id")
                    return false
            }
            updateUser.groupId = groupId
            try managedContext.save()
        } catch let error as NSError {
            Log.info(error)
        }
        return true
    }
    
    
    func getUser(with id: String, context: NSManagedObjectContext? = nil) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let results: [User]
            if let privateContext = context {
               results = try privateContext.fetch(request)
            } else {
                results = try coreDataManager.viewContext.fetch(request)
            }
            return results.first
        } catch {
            return nil
        }
    }
    
    func deleteUser(for userid: String) -> Bool {
        let fetch:NSFetchRequest<User> = User.fetchRequest()
        fetch.predicate = NSPredicate(format: "userId = [cd] %@", userid)
        
        do {
            let result = try coreDataManager.viewContext.fetch(fetch)
            if result.isEmpty {
                //Nothing to delete
                return false
            }
//            if result.count > 1 {
//                print("TOO MANY QUIZZES TO DELETE")
//                return false
//            }
            guard result.first != nil else { return false }
            for user in result{
                coreDataManager.viewContext.delete(user)
            }

            try coreDataManager.viewContext.save()
            return true
        } catch {
            print("Failed to delete from Core data: \(error)")
            return false
        }
    }
}
