import Foundation
import CoreData

extension GroupQuizResult {
    
    func populate(from groupQuizResult: GroupQuizAnswerForCD) throws {
        self.isCorrect = groupQuizResult.isCorrect
        self.points = groupQuizResult.points
        self.value = groupQuizResult.value
        self.questionId = groupQuizResult.questionId
        self.quizId = groupQuizResult.quizId
    }
    
    static func fetch(from groupQuizResult: GroupQuizAnswerForCD) -> GroupQuizResult? {
        let fetch: NSFetchRequest<GroupQuizResult> = GroupQuizResult.fetchRequest()
        fetch.predicate = NSPredicate(format: "id = [cd] %@", groupQuizResult.quizId)
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



