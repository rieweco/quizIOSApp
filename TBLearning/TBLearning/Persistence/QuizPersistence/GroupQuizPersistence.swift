import Foundation
import CoreData

class GroupQuizPersistence {
    let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    //For create new result record in coredata
    private func createRecordForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        // Helpers
        var result: NSManagedObject?
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        
        if let entityDescription = entityDescription {
            // Create Managed Object
            result = NSManagedObject(entity: entityDescription, insertInto: managedObjectContext)
        }
        
        return result
    }
    
    func getGroupQuizResult() -> [GroupQuizResult]{
        let request: NSFetchRequest<GroupQuizResult> = GroupQuizResult.fetchRequest()
        do {
            let results = try coreDataManager.persistentContainer.viewContext.fetch(request)
            return results
        } catch {
            return []
        }
    }
    
   
    
    //persistQuiz
    func saveGroupQuizResult(groupQuiz: GroupQuizAnswerForCD, complete: (() -> Void)?) {
        let managedContext = coreDataManager.persistentContainer.viewContext
        let questionEntity = NSEntityDescription.entity(forEntityName: "GroupQuizResult", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "questionId = [cd] %@", groupQuiz.questionId)
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            if fetchResults.isEmpty{
                let groupQuizEntity = NSEntityDescription.entity(forEntityName: "GroupQuizResult", in: managedContext)!
                let currentGroupQuizResult = NSManagedObject(entity: groupQuizEntity, insertInto: managedContext)
                currentGroupQuizResult.setValue(groupQuiz.isCorrect, forKey: "isCorrect")
                currentGroupQuizResult.setValue(groupQuiz.points, forKey: "points")
                currentGroupQuizResult.setValue(groupQuiz.questionId, forKey: "questionId")
                currentGroupQuizResult.setValue(groupQuiz.quizId, forKey: "quizId")
                currentGroupQuizResult.setValue(groupQuiz.value, forKey: "value")
                try managedContext.save()
            }else{
                for answer in fetchResults{
                    managedContext.delete(answer as! NSManagedObject)

                }
                try managedContext.save()
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
        
     
        //get groupQuiz results from core Data
        func getGroupQuizScore(with check: String, complete: (() -> Void)?) -> [Int16]{
            let managedContext = coreDataManager.persistentContainer.viewContext
            //    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
            var resultArray = [Int16]()
            let questionEntity = NSEntityDescription.entity(forEntityName: "GroupQuizResult", in: managedContext)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = questionEntity!
            let fetchResults = try? managedContext.fetch(fetchRequest)
            if let results = fetchResults {
                results.forEach({ (result) in
                    let requiredQuestion = result as! GroupQuizResult
                    resultArray.append(requiredQuestion.points)
                })
                
            }
            do {
                try managedContext.save()
                Log.info("answer saved ~~~~~")
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            return resultArray
            complete?()
        }
    
    func deleteGroupQuizResult(for quizId: String) -> Bool{
        let managedContext = coreDataManager.persistentContainer.viewContext
        let quizEntity = NSEntityDescription.entity(forEntityName: "GroupQuizResult", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = quizEntity!
        fetchRequest.predicate = NSPredicate(format: "quizId = [cd] %@", quizId)
        
        
        
        do {
            let fetchResults = try? managedContext.fetch(fetchRequest)
            let results = fetchResults as? [NSManagedObject]
            
            guard let _ = results?.first else { return false }
            for result in results!{
                managedContext.delete(result)
            }
            
            try managedContext.save()
            return true
        } catch {
            print("Failed to delete from Core data: \(error)")
            return false
        }
    }
}

