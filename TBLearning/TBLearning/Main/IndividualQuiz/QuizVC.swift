import UIKit

private let reuseIdentifier = "QuestionsCell"

class QuizVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitQuizButton: UIButton!
    @IBOutlet weak var navigationbar: UINavigationBar!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    let individualQuizService = IndividualQuizService()
    let groupQuizService = GroupQuizService()

    //Application Session persist user data
    let session = DataManager()
    
    var qzId: String?
    var tkn: String?
    var crsId: String?
    var selectedQuestion: ServiceQuestion? // used to pass question object to QuestionDetailVC
    var selectedQuestionIndex: Int?
    var timer: Timer!//for timer slider
    var start: Float = 0.0 //timerslider initial position
    var labelTimer: Timer!//for timer Label
    var timeInterval: TimeInterval = 0.0
    var labelTimerInterval: TimeInterval = 0.0
    var seconds = 60// for seconds
    var isBackUser: Bool?// for backInUser
    var isQuizComplete: Bool? //for backInUser
    //core data test delete later
    var userInfo = UserInfo(userId: "")
    var users: [User] = []
    var usersInfo: [UserInfo] = []
    
    //vars for CollectionView layouts
    private let leftAndRightPaddings: CGFloat = 20.0
    private let numberOfItemsPerRow: CGFloat = 3.0
    private let heightAdjustment: CGFloat = 30.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        individualQuizService.quizModelDelegate = self
        individualQuizService.postIndividualQuizDelegate = self
        groupQuizService.startPullGroupStatusDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        self.navigationbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: (self.view.frame.height * 0.10))
        
        
        //update collectionView if questions status updated
        //  if question is complete, update its bgColor in CollectionView
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView), name: .updateCollectionView, object: nil)
        
        //timerSlider Setting
        timerSlider.isUserInteractionEnabled = false
        timerSlider.maximumValue = Float((IndividualQuizService.quizWithToken?.quiz.timedLength)!)
        timerSlider.setThumbImage(#imageLiteral(resourceName: "clock"), for: .normal)
        updateTimer()
        updateTimerLabel()
        //hidden and disable the submit Quiz button until all the question completed
        self.submitQuizButton.isHidden = true
        self.submitQuizButton.isEnabled = false
        
        //persist User info into coredata
        guard let _ = self.isBackUser,
            let isQuizAnswerFilled = self.isQuizComplete else{
            let userData = UserInfo(userId: IndividualQuizService.quizUserId!, courseId: IndividualQuizService.quizCourseId!, token: tkn!, isLeader: nil, quizId: IndividualQuizService.quizWithToken?.quiz.id, quizStartTime: IndividualQuizService.quizStartTime!, quizTimed: true, quizTimeLength: IndividualQuizService.quizWithToken?.quiz.timedLength, sessionId: IndividualQuizService.quizWithToken?.sessionId,
                                    status: "inIndividualQuiz", groupId: "")
            session.userPersistence.insertUserInfo(with: userData, complete: nil)
            return
        }
        if isQuizAnswerFilled {
            self.submitQuizButton.isHidden = false
            self.submitQuizButton.isEnabled = true
        }

    }
    func updateTimer(){
            timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(QuizVC.updateSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateSlider(){
        if self.timerSlider.value == self.timerSlider.maximumValue{

            if let topController = UIApplication.topViewController() {
                let alert = UIAlertController(title:"Time Out", message: "You have to turn in the Quiz", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler:{ action in
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    do {
                        let newTodoAsJSON = try QuizPayLoad(quizId: IndividualQuizService.quizId!, questions: IndividualQuizService.postQuizQuestions ).encode()
                        print(String(data: newTodoAsJSON, encoding: .utf8) ?? "no body data")
                        self.individualQuizService.loadQuizResult(userId: LoginService.userId!, courseId: IndividualQuizService.quizCourseId!, sessionId: IndividualQuizService.quizSessionId!, quiz: newTodoAsJSON)
                    } catch {
                        print(error)
                    }
                }))
                topController.present(alert, animated: true, completion: nil)
            }
            timer.invalidate()
            labelTimer.invalidate()
        }
        start += 0.25
        self.timerSlider.setValue(start, animated: true)
    }
    
    func updateTimerLabel(){
        labelTimerInterval =  TimeInterval((IndividualQuizService.quizWithToken?.quiz.timedLength)!) * 60 -   timeInterval
        labelTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(QuizVC.updateLabelTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateLabelTimer(){
        labelTimerInterval -= 1
        self.timerLabel.text = timeString(time: labelTimerInterval)
        if self.labelTimerInterval <= 0{
            self.timerLabel.text = "00:00"
            if let topController = UIApplication.topViewController() {
                let alert = UIAlertController(title:"Time Out", message: "You have to turn in the Quiz", preferredStyle: .alert)

                alert.view.layer.cornerRadius = 25
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler:{ action in
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    do {
                        let newTodoAsJSON = try QuizPayLoad(quizId: IndividualQuizService.quizId!, questions: IndividualQuizService.postQuizQuestions ).encode()
                        print(String(data: newTodoAsJSON, encoding: .utf8) ?? "no body data")
                        self.individualQuizService.loadQuizResult(userId: LoginService.userId!, courseId: IndividualQuizService.quizCourseId!, sessionId: IndividualQuizService.quizSessionId!, quiz: newTodoAsJSON)
                    } catch {
                        print(error)
                    }
                }))
                topController.present(alert, animated: true, completion: nil)
            }
            timer.invalidate()
            labelTimer.invalidate()
        }else{
             NotificationCenter.default.post(name:Notification.Name(rawValue:"timerNotification"),
                    object: nil,
                    userInfo: ["timeString":timeString(time: labelTimerInterval)])
        }

    }
    
    func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    @IBAction func submitQuizButtonTapped(_ sender: UIButton) {
        
        // QuizPayLoad struct object fetched from coreData, call encode() converting it into JSONData
        // then pass into quizModel.loadQuizResult() func, replace the newTodoAsJSON with JSONData just created
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        
        do {
            let newTodoAsJSON = try QuizPayLoad(quizId: IndividualQuizService.quizId!, questions: IndividualQuizService.postQuizQuestions ).encode()
            print(String(data: newTodoAsJSON, encoding: .utf8) ?? "no body data")
            individualQuizService.loadQuizResult(userId: LoginService.userId!, courseId: IndividualQuizService.quizCourseId!, sessionId: IndividualQuizService.quizSessionId!, quiz: newTodoAsJSON)
        } catch {
            print(error)
        }
        //stop timer~ if user submit quiz within required time limit
        self.timer.invalidate()
        self.labelTimer.invalidate()
        
    }
    
    
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "LogoutSegue", sender: self)
        //reset IndividualQuizService static vars****
        self.individualQuizService.resetIndividualQuizData()
    }
    
    @IBAction func unwindToQuizCollectionView(segue:UIStoryboardSegue) {
        //Both ways works
        //#way1
        NotificationCenter.default.post(name: .updateCollectionView, object: self)
        //#way2
        //        Log.info(IndividualQuizService.quizIsComplete)
        //        self.collectionView.reloadData()
        //        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    @objc func updateCollectionView(){
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension QuizVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
        let width = (collectionView.contentSize.width - (insets.left + insets.right + leftAndRightPaddings)) / numberOfItemsPerRow
        return CGSize(width: width, height: (width + heightAdjustment))
    }
}

extension QuizVC: UICollectionViewDataSource{
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return IndividualQuizService.quizWithTokenQuestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! QuizCollectionViewCell
        let selectedQuestion = IndividualQuizService.quizWithTokenQuestions[indexPath.row]
        cell.selectedQuestion = selectedQuestion
        let question = session.individualQuizPersistence.getCompleteQuestions(with: selectedQuestion.id, complete: nil)
        
        if question[0].status == "inComplete"{
            cell.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
        } else if question[0].status == "notFullFilled"  {
            cell.backgroundColor = UIColor.yellow
        }else{
            cell.backgroundColor = UIColor(red: 0, green: 254/255, blue: 138/255, alpha: 1)
        }
        let points = session.individualQuizPersistence.getQuestionAllocatedPoints(questionId: (cell.selectedQuestion?.id)!, complete: nil)
        cell.pointsAllocated.text = String(points)
        return cell
    }
}

extension QuizVC: UICollectionViewDelegate{
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedQuestion = IndividualQuizService.quizWithTokenQuestions[indexPath.row]
        selectedQuestionIndex = indexPath.row
        self.performSegue(withIdentifier: "showQuestionDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuestionDetailSegue"{
            let destVC = segue.destination as! QuizQuestionVC
            destVC.selectedQuestion = self.selectedQuestion
            destVC.questionNumber = self.selectedQuestionIndex
            destVC.selectedQuestionIndex = self.selectedQuestionIndex
        }
    }
}


extension QuizVC: QuizModelDelegate{
    func dataQuizUpdate() {
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        //assign the quiz endTime
        IndividualQuizService.quizStartTime = Date(timeInterval: Double((IndividualQuizService.quizWithToken?.quiz.timedLength)!*60), since: Date())
        Log.info(Date())
        Log.info(IndividualQuizService.quizStartTime)
        

    }
    
    func QuizNoExist() {
        Log.info("unused")
    }
}

extension QuizVC: PostIndividualQuizRespsonseDelegate{
    func postIndividualQuizResult(){
        if let topController = UIApplication.topViewController() {
        let alert = UIAlertController(title:"Post Quiz", message: "Quiz has successfully submitted", preferredStyle: .alert)
        alert.view.layer.cornerRadius = 25
        
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler:{ action in
            
            self.groupQuizService.loadGroupInfo(userId: LoginService.userId!, courseId: IndividualQuizService.quizCourseId!)
            Log.info(IndividualQuizService.quizId!)
        }))
        topController.present(alert, animated: true, completion: nil)
        
        }
    }
}

extension QuizVC: StartPullGroupStatusNetworkCallDelegate{
    func startPullingGroupStatus(){
        //persist the individual quiz score into core data
        let submittedResults = IndividualQuizService.quizAnswers
        if !submittedResults.isEmpty{
            submittedResults.forEach({ (submitResult) in
                submitResult.submittedAnswers.forEach({ (result) in
                    if result.isCorrect{
                        session.individualQuizPersistence.updateQuestionScore(questionId: submitResult.question, score: result.points, complete: nil)
                    }
                })
            })
        }
        if let topController = UIApplication.topViewController() {
            topController.performSegue(withIdentifier: "completeQuizSegue", sender: self)
        }
    }
}



