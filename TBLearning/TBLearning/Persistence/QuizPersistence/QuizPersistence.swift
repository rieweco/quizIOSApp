import Foundation
import CoreData

class QuizPersistence{
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
    
    
    
    func insertEmptyQuizFromService(with data: Data, complete:(() -> Void)?){
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let serviceQuiz: GetQuizWithToken!
        do{
            serviceQuiz = try decoder.decode(GetQuizWithToken.self, from: data)
            print(serviceQuiz)
        } catch let error as NSError{
            print("Failed to parse: \(error)")
            complete?()
            return
        }
        
        coreDataManager.persistentContainer.performBackgroundTask { (backgroundContext) in
            do {
                let quiz: Quiz
                if let existingQuiz = Quiz.fetch(from: serviceQuiz.quiz){
                    quiz = existingQuiz
                } else {
                    quiz = Quiz(context: backgroundContext)
                }
                
                try quiz.populate(from: serviceQuiz.quiz)
                try backgroundContext.save()
                
            } catch let error as NSError {
                print(error)
            }
            complete?()
        }
        
    }
    
    func getQuiz() -> Quiz? {
        let request: NSFetchRequest<Quiz> = Quiz.fetchRequest()
        do {
            let results = try coreDataManager.persistentContainer.viewContext.fetch(request)
            return results.first
        } catch {
            return nil
        }
    }
    
    func getQuiz(with id: String, context: NSManagedObjectContext? = nil) -> Quiz? {
        let request: NSFetchRequest<Quiz> = Quiz.fetchRequest()
        do {
            let results: [Quiz]
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
    
    
    func deleteQuiz(for id: String) -> Bool {
        let managedContext = coreDataManager.persistentContainer.viewContext
        let quizEntity = NSEntityDescription.entity(forEntityName: "Quiz", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = quizEntity!
        fetchRequest.predicate = NSPredicate(format: "id = [cd] %@", id)
        
        
        do {
            let fetchResults = try? managedContext.fetch(fetchRequest)
            let results = fetchResults as? [NSManagedObject]
            guard let _ = results?.first else { return false }
            results?.forEach({ (result) in
                managedContext.delete(result)
            })
            try managedContext.save()
            return true
        } catch {
            print("Failed to delete from Core data: \(error)")
            return false
        }
    }
    
    //persistQuiz
    func saveQuiz(quiz: ServiceQuiz, complete: (() -> Void)?) {
        let managedContext = coreDataManager.persistentContainer.viewContext
        //    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
        
        let questionEntity = NSEntityDescription.entity(forEntityName: "Quiz", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "id = [cd] %@", quiz.id)
                do {
        let fetchResults = try managedContext.fetch(fetchRequest)
        if fetchResults.isEmpty {
                let quizEntity = NSEntityDescription.entity(forEntityName: "Quiz", in: managedContext)!
                let currentQuiz = NSManagedObject(entity: quizEntity, insertInto: managedContext)
                currentQuiz.setValue(quiz.id, forKey: "id")
                currentQuiz.setValue(quiz.availableDate, forKey: "availableDate")
                currentQuiz.setValue(quiz.desc, forKey: "desc")
                currentQuiz.setValue(quiz.expiryDate, forKey: "expiryDate")
                currentQuiz.setValue(quiz.text, forKey: "text")
                currentQuiz.setValue(quiz.timed, forKey: "timed")
                currentQuiz.setValue(quiz.timedLength, forKey: "timedLength")
                try managedContext.save()
            }
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        complete?()
    }

    
    private func fetchRequest(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        // Helpers
        var result = [NSManagedObject]()
        
        do {
            // Execute Fetch Request
            let records = try managedObjectContext.fetch(fetchRequest)
            
            if let records = records as? [NSManagedObject] {
                result = records
            }
            
        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }
        
        return result
    }
    
    
    //Persist Questions
    
    func saveQuestionAnswer(question: ServiceQuestion, quizId: String, complete: (() -> Void)?){
        let managedContext = coreDataManager.persistentContainer.viewContext
        var quiz: NSManagedObject? = nil
        let quizes = fetchRequest("Quiz", inManagedObjectContext: managedContext)
        
        if let quizList = quizes.first {
            quiz = quizList
        }

        if let quiz = quiz {
            print(quiz.value(forKey: "id") ?? "no id")
        }
        let currentQuestion = quiz?.mutableSetValue(forKey: "questions")
        let completedQuestions = self.getCompleteQuestionsByStatus(with: "completed", complete: nil)
        let notFullFilledQuestions = self.getCompleteQuestionsByStatus(with: "notFullFilled", complete: nil)
        
        if notFullFilledQuestions.isEmpty && completedQuestions.isEmpty{
            if let newQuestion = createRecordForEntity("Question", inManagedObjectContext: managedContext) {
                newQuestion.setValue(question.id, forKeyPath: "id")
                newQuestion.setValue(question.pointsPossible, forKeyPath: "points")
                newQuestion.setValue(question.text, forKey: "text")
                newQuestion.setValue(question.title, forKey: "title")
                newQuestion.setValue("inComplete", forKey:"status")
                newQuestion.setValue(0, forKey: "score")
                currentQuestion?.add(newQuestion)
                
                let questionAnswers = newQuestion.mutableSetValue(forKey: "answer")
                var pointsIndex = 0
                let answers: [ServiceAnswers] = question.availableAnswers!
                
                for (answer) in answers {
                    if let newAnswer = createRecordForEntity("Answer", inManagedObjectContext: managedContext) {
                        newAnswer.setValue(answer.text, forKey: "text")
                        newAnswer.setValue(answer.value, forKey: "value")
                        newAnswer.setValue(answer.sortOrder, forKey: "sortId")
                        newAnswer.setValue(0, forKey: "points")
                        newAnswer.setValue(question.id, forKey: "questionId")
                        if let imageUri = answer.imageUri{
                            newAnswer.setValue(imageUri, forKey: "imageUri")
                        }
                        questionAnswers.add(newAnswer)
                        
                        pointsIndex = pointsIndex + 1
                        
                    }
                }
            }
        }
        
        do {
            try managedContext.save()
            print("I DID IT!!!!!!!!!!!!!!!!!!!!!!!!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        complete?()
        
    }
    
    
    //Update question answer

    
    func updateQuestionAnswer(questionId: String, answerArray: [Int16], complete: (() -> Void)?){
    let managedContext = coreDataManager.persistentContainer.viewContext
//    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
    
        let questionEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "id = [cd] %@", questionId)
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            var requiredQuestion : Question
            if (results.count > 0) {
                requiredQuestion = results[0] as! Question
                requiredQuestion.answer?.forEach({ (answer) in
                    for (index, answerPoint) in answerArray.enumerated(){
                        if index == (answer as! Answer).sortId{
                            (answer as! Answer).setValue(answerPoint, forKey: "points")
                        }
                    }
                })
                
            }

        }
        do {
            try managedContext.save()
            Log.info("answer saved ~~~~~")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    complete?()
    }
    
    func updateQuestionScore(questionId: String, score: Int16, complete: (() -> Void)?){
        let managedContext = coreDataManager.persistentContainer.viewContext
        //    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
        
        let questionEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "id = [cd] %@", questionId)
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            var requiredQuestion : Question
            if (results.count > 0) {
                requiredQuestion = results[0] as! Question
                requiredQuestion.setValue(score, forKey: "score")
                
            }
            
        }
        do {
            try managedContext.save()
            Log.info("answer saved ~~~~~")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        complete?()
    }
    
    func getIndividualQuizScore(with check: String, complete: (() -> Void)?) -> [Int16]{
        let managedContext = coreDataManager.persistentContainer.viewContext
        //    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
        var resultArray = [Int16]()
        let questionEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            results.forEach({ (result) in
                let requiredQuestion = result as! Question
                resultArray.append(requiredQuestion.score)
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
    
    
    
    
    
    func getQuestionAllocatedPoints(questionId: String, complete: (() -> Void)?) ->Int16{
        let managedContext = coreDataManager.persistentContainer.viewContext
        //    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
        
        let questionEntity = NSEntityDescription.entity(forEntityName: "Answer", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "questionId = [cd] %@", questionId)
        let fetchResults = try? managedContext.fetch(fetchRequest)
        var sumPoints: Int16 = 0
        if let results = fetchResults {
            if (results.count > 0) {
                results.forEach({ (answer) in
                    let ans = answer as! Answer
                    sumPoints += ans.points
                })
            }else{return 0}
        }
        do {
            try managedContext.save()
            Log.info("get question points```")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return sumPoints
        complete?()
    }
    
    func updateQuestionStatus(questionId: String, status: String, complete: (() -> Void)?){
        let managedContext = coreDataManager.persistentContainer.viewContext
        //    let questions = fetchRequest("Question", inManagedObjectContext: managedContext)
        
        let questionEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "id = [cd] %@", questionId)
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            if (results.count > 0) {
                results.forEach({ (question) in
                    let ques = question as! Question
                    ques.setValue(status, forKey: "status")
                })
                
            }
            
        }
        do {
            try managedContext.save()
            Log.info("answer saved ~~~~~")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        complete?()
    }
    
    func getCompleteQuestionsByStatus(with status: String,complete: (() -> Void)?) -> [Question]{
        let managedContext = coreDataManager.persistentContainer.viewContext
        var questions = [Question]()
        let questionEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            results.forEach({ (answer) in
                let result = answer as! Question
                if result.status! == status{
                     questions.append(result)
                }
            })
        }
    return questions
    complete?()
    }
    
    func getCompleteQuestions(with questionId: String,complete: (() -> Void)?) -> [Question]{
        let managedContext = coreDataManager.persistentContainer.viewContext
        var questions = [Question]()
        let questionEntity = NSEntityDescription.entity(forEntityName: "Question", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            results.forEach({ (answer) in
                let result = answer as! Question
                if result.id == questionId{
                    questions.append(result)
                }
            })
        }
        return questions
        complete?()
    }
    
    func getQuestionAnswerArray(questionId: String, complete: (() -> Void)?) ->[Answer]{
        let managedContext = coreDataManager.persistentContainer.viewContext
        var answers = [Answer]()
        let questionEntity = NSEntityDescription.entity(forEntityName: "Answer", in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = questionEntity!
        fetchRequest.predicate = NSPredicate(format: "questionId = [cd] %@", questionId)
        let fetchResults = try? managedContext.fetch(fetchRequest)
        if let results = fetchResults {
            results.forEach({ (answer) in
                let result = answer as! Answer
                answers.append(result)
            })

        }
        return answers
        complete?()
    }
    
}
