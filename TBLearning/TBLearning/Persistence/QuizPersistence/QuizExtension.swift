import Foundation
import CoreData

extension Quiz {
    
    func populate(from quiz: ServiceQuiz) throws {
        self.id = quiz.id
        self.desc = quiz.desc
        self.availableDate = quiz.availableDate
        self.timed = quiz.timed
        self.timedLength = quiz.timedLength
        self.text = quiz.text
        self.expiryDate = quiz.expiryDate
    }
    
    static func fetch(from quiz: ServiceQuiz) -> Quiz? {
        let fetch: NSFetchRequest<Quiz> = Quiz.fetchRequest()
        fetch.predicate = NSPredicate(format: "id = [cd] %@", quiz.id)
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


