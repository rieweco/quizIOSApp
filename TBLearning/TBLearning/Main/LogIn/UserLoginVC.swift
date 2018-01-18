import UIKit
//import Parse.h
class UserLoginVC: UIViewController {
    
    @IBOutlet weak var UserSsoIdTextField: UITextField!
    
    let loginService = LoginService()
    let individualQuizService = IndividualQuizService()
    let groupQuizService = GroupQuizService()
    
    //test using application session load user data
    let session = DataManager()
    var user: User? = nil{
        didSet{
            guard let _ = user else {return}
            handleComeBackUser()
        }
    }
    var userInfo = UserInfo(userId: "")
    var inIndividualQuiz: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginService.checkCourseDelegate = self
        loginService.getCourseDelegate = self
        self.UserSsoIdTextField.delegate = self
        individualQuizService.quizModelDelegate = self
        
        //change navigation bar style
        navigationController?.setNavigationBarHidden(false, animated: true)
        //custom NavigationBar for all views
        UINavigationBar.appearance().backgroundColor = UIColor.blue
        let titleFont = [ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 25)! ]
        UINavigationBar.appearance().titleTextAttributes = titleFont
    }
    
    @IBAction func dissmissPopupButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToLogIn(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "ShowCourses" {
            if let destination = segue.destination as? UINavigationController{
                let destVC = destination.topViewController as! CourseListTableViewController
                destVC.userId = UserSsoIdTextField.text!
            }
        } else if segue.identifier! == "backUserSegue"{
            if let destVC = segue.destination as? QuizVC{
                let date2 = Date.init()
                let timeInterval = date2.timeIntervalSince(userInfo.quizStartTime!)
                destVC.timeInterval = timeInterval
                destVC.start = Float(timeInterval/60)//for timer slider
                destVC.isBackUser = true
                if individualQuizService.isIndividualQuizComplete(){
                    destVC.isQuizComplete = true
                }else{
                    destVC.isQuizComplete = false
                }
            }
        }else if segue.identifier! == "backToGroupQuizAsLeaderSegue"{
            if let destVC = segue.destination as? groupQuizVC{
                let completeQuestionCount  = session.groupQuizPersistence.getGroupQuizResult().count
                GroupQuizService.groupQuizQuestionIndex = completeQuestionCount
                if completeQuestionCount == IndividualQuizService.postQuizQuestions.count{
                    destVC.isGroupQuizComplete = true
                }
            }
        }
    }
    
    
    @IBAction func LoginButtonTapped(_ sender: UIButton) {
        //validate UserInfo
        guard
            let userSSOID = self.UserSsoIdTextField.text, !userSSOID.isEmpty
            else{
                AlertController.showAlert(self, title: "Missing User Info", message: "Please enter your ssoid")
                return
        }
        if(userSSOID.removingWhiteSpaces().count <= 3){
            AlertController.showAlert(self, title: "Missing User Info", message: "SSOID has to be greater than three characters")
            return
        } else {
            LoginService.userId = userSSOID
            user = session.userPersistence.getUser(with: userSSOID)
            //backIn User
            if user?.userId == userSSOID{
                if let raw = UserStatus(rawValue: (user?.status!)!){
                    switch raw{
                    case .inIndividualQuiz:
                        inIndividualQuiz = true
                        individualQuizService.loadQuizWithToken(userName: userInfo.userId, classId: userInfo.courseId!, quizId: userInfo.quizId!, token: userInfo.token!)
                    case .inWaitingRoom:
                        populateIndividualQuizData()
                    case .inGroupQuiz:
                        if userInfo.isLeader!{
                            populateIndividualQuizData()
                            groupQuizService.loadGroupStatus(groupId: userInfo.groupId!, courseId: userInfo.courseId!, quizId: userInfo.quizId!, sessionId: userInfo.sessionId!)

                        }else{
                            populateIndividualQuizData()

                            
                        }
                    case .complete:
                        Log.info("this quiz has completed")
                        loginService.loadQuizes(with: userSSOID)
                    }
                }
            }else{
                loginService.loadQuizes(with: userSSOID)
            }
        }
        
    }
    
    func handleComeBackUser(){
        do {
            try userInfo.populate(from: user!)
        } catch  {
            Log.info("userInfo populate from user error ")
        }
        
        Log.info(userInfo)
        
    }
    
    
    func populateIndividualQuizData(){
        individualQuizService.resetIndividualQuizData()
        individualQuizService.loadQuizWithToken(userName: userInfo.userId, classId: userInfo.courseId!, quizId: userInfo.quizId!, token: userInfo.token!)
        IndividualQuizService.quizId = userInfo.quizId
        IndividualQuizService.quizSessionId = userInfo.sessionId
        GroupQuizService.grpId = userInfo.groupId
        IndividualQuizService.quizCourseId = userInfo.courseId
    }
    
}

extension UserLoginVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
extension UserLoginVC: CheckCoursesExistDelegate{
    func checkCourseExist() {
        AlertController.showAlert(self, title: "Invalid User", message: "User doesn't exist, please try again!")
    }
}

extension UserLoginVC: GetCoursesDelegate{
    func dataUpdate() {
        performSegue(withIdentifier: "ShowCourses", sender: self)
    }
}
extension UserLoginVC: QuizModelDelegate{
    func dataQuizUpdate() {
        if let raw = UserStatus(rawValue: (user?.status!)!){
            switch raw{
            case .inIndividualQuiz:
                individualQuizService.populateQuestionAnswers()
                performSegue(withIdentifier: "backUserSegue", sender: self)
            case .inWaitingRoom:

                individualQuizService.populateQuestionAnswers()
                performSegue(withIdentifier: "backToWaitingRoomSegue", sender: self)
            case .inGroupQuiz:
                if userInfo.isLeader!{
                    individualQuizService.populateQuestionAnswers()
                    performSegue(withIdentifier: "backToGroupQuizAsLeaderSegue", sender: self)
                }else{
                    individualQuizService.populateQuestionAnswers()
                    groupQuizService.loadGroupStatus(groupId: userInfo.groupId!, courseId: userInfo.courseId!, quizId: userInfo.quizId!, sessionId: userInfo.sessionId!)
                    performSegue(withIdentifier: "backToGroupQuizAsMemberSegue", sender: self)
                }
            case .complete:
                Log.info("Should not shown this message, quiz has submitted~~~")
            }
        }
        
    }
}
