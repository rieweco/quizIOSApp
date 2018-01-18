import Foundation
import CoreData

extension User {
    func populate(from user: UserInfo) throws {
        self.userId = user.userId
        self.courseId = user.courseId
        self.token = user.token
        self.isLeader = user.isLeader ?? false
        self.quizId = user.quizId
        self.quizStartTime = user.quizStartTime
        self.quizTimed = user.quizTimed ?? false
        self.quizTimedLength = user.quizTimeLength ?? 0
        self.sessionId = user.sessionId
        self.status = user.status
    }
    
        static func fetch(from user: UserInfo) -> User? {
            let fetch: NSFetchRequest<User> = User.fetchRequest()
            fetch.predicate = NSPredicate(format: "userId = [cd] %@", user.userId)
            do {
                let results = try fetch.execute()
                if results.count > 1 || results.isEmpty {
                    return nil
                }
                return results.first
            } catch let error as NSError {
                print(error)
                return nil
            }
        }
    static func fetch(with userId: String) -> User? {
        let fetch: NSFetchRequest<User> = User.fetchRequest()
        fetch.predicate = NSPredicate(format: "userId = [cd] %@", userId)
        do {
            let results = try fetch.execute()
            if results.count > 1 || results.isEmpty {
                return nil
            }
            return results.first
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
}
