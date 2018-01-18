import Foundation

protocol QuizModelDelegate: class {
    func dataQuizUpdate()
}

protocol CheckIsCorrectTokenDelegate: class {
    func quizNoExist()
}

protocol PostIndividualQuizRespsonseDelegate: class{
    func postIndividualQuizResult()
}

class IndividualQuizService{
    weak var quizModelDelegate: QuizModelDelegate?
    weak var postIndividualQuizDelegate: PostIndividualQuizRespsonseDelegate?
    weak var checkTokenDelegate: CheckIsCorrectTokenDelegate?
    var quizPersist = QuizPersistence(coreDataManager: CoreDataManager())
    
    static var quizWithToken: GetQuizWithToken?
    static var quizStartTime: Date?
    static var quizUserId: String?
    static var quizCourseId: String?
    static var quizId: String?
    static var quizWithTokenQuestions = [ServiceQuestion]()
    static var quizSessionId: String?
    static var quizIsComplete = [String]()
    
    //post individual quiz http reponse data
    static var quizResult: QuizResult?
    static var quizAnswers = [AnswerResult]()
    static var quizSubmittedAnswers = [SubmitAnswer]()

    //quesiton allocated points array
    static var questionAllocatedPointsArray = [Int16]()
    
    //post individual quiz body vars 
    static var postQuizSubmittedAnswers = [SubmittedAnswers]()
    static var postQuizQuestions = [QuestionPayLoad]()
    static var postQuiz: QuizPayLoad?
    
    private let serviceClient = ServiceClient()
    
    //check quiz populated do delege.updatedata func
    private(set) var isQuizPopulated: Bool? {
        didSet{
            if isQuizPopulated! {
                quizModelDelegate?.dataQuizUpdate()
            }else{
                checkTokenDelegate?.quizNoExist()
            }
            
        }
    }
    //check post quiz result do delegate.postResult func
    private(set) var isQuizPostResultReceived: Bool?{
        didSet{
            if isQuizPostResultReceived! {
                postIndividualQuizDelegate?.postIndividualQuizResult()
            }
        }
    }
    
    func resetIndividualQuizData(){
        IndividualQuizService.quizWithTokenQuestions.removeAll()
        IndividualQuizService.quizIsComplete.removeAll()
        IndividualQuizService.postQuizQuestions.removeAll()
    }
    
    func loadQuizWithToken(userName user: String, classId id: String, quizId qzId: String, token tk: String){
        serviceClient.getAllQuizes(userName: user, classId: id, quizId: qzId, token: tk){ (quizes) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                if let individualQuiz = quizes {
                    //persist Quiz
                    weakSelf.quizPersist.saveQuiz(quiz: individualQuiz.quiz, complete: nil)
                    
                    IndividualQuizService.quizWithToken = individualQuiz
                    IndividualQuizService.quizStartTime = Date?.init(Date.init())
                    IndividualQuizService.quizUserId = user
                    IndividualQuizService.quizCourseId = id

                    IndividualQuizService.quizId = individualQuiz.quiz.id
                    if let questions = IndividualQuizService.quizWithToken?.quiz.questions{
                        
                        IndividualQuizService.quizSessionId = IndividualQuizService.quizWithToken?.sessionId

                        for question in questions{
                            
                            weakSelf.quizPersist.saveQuestionAnswer(question: question, quizId: individualQuiz.quiz.id, complete: {
                                Log.info("quiz question Persisted~~~~")
                            })
                            IndividualQuizService.quizWithTokenQuestions.append(question)
                                IndividualQuizService.quizIsComplete.append("inComplete")
                        }
                    }
                    weakSelf.isQuizPopulated = true
                } else {
                    weakSelf.isQuizPopulated = false
                }
            }
        }
    }
    
    func loadQuizResult(userId: String, courseId: String, sessionId: String,quiz: Data){
        serviceClient.postAnswers(userId: userId, courseId: courseId, sessionId: sessionId,quiz: quiz){ (postResponseQuizResult) in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                if let quizArray = postResponseQuizResult {
                    IndividualQuizService.quizResult = quizArray
                    if let ans = IndividualQuizService.quizResult?.answers{
                        for answer in ans{
                            IndividualQuizService.quizAnswers.append(answer)
                            for submittedAnswer in answer.submittedAnswers{
                            IndividualQuizService.quizSubmittedAnswers.append(submittedAnswer)
                            }
                        }
                        weakSelf.isQuizPostResultReceived = true
                        
                    } else {
                        print("no course enrolled this semester")
                    }
                    weakSelf.isQuizPostResultReceived = false
                }
            }
        }
    }
    
    //populate save question answers into postQuizQuestions
    func populateQuestionAnswers(){
        var submitAnswers = [SubmittedAnswers]()
        var questionPayLoads = [QuestionPayLoad]()
        var questions =  self.quizPersist.getCompleteQuestionsByStatus(with:"notFullFilled", complete: nil)
        let questions2 = self.quizPersist.getCompleteQuestionsByStatus(with: "completed", complete: nil)
        
        questions2.forEach { (quesiton) in
            questions.append(quesiton)
        }
        
        questions.forEach { (question) in
            let answers = quizPersist.getQuestionAnswerArray(questionId: question.id!, complete: nil)
            for answer in answers{
                if answer.points != 0 {
                    submitAnswers.append(SubmittedAnswers(value: answer.value!, allocatedPoints: answer.points))
                }
            }
            
            questionPayLoads.append(QuestionPayLoad(quesId: question.id!, submittedAnswers: submitAnswers))
            submitAnswers.removeAll()
        }
        IndividualQuizService.postQuizQuestions = questionPayLoads
    }
    
    func isIndividualQuizComplete() -> Bool{
        if IndividualQuizService.postQuizQuestions.count == 10{
            return true
        }
        return false
    }
}
