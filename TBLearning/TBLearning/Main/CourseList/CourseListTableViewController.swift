import UIKit

/*Save Courses Information into QuizesModel class satic variable */

class CourseListTableViewController: UITableViewController {
    
    var userId: String?
    var quizToken: String?
    var selectedCourseIndex: Int?
    let individualQuizService = IndividualQuizService()
    override func viewDidLoad() {
        super.viewDidLoad()
        individualQuizService.checkTokenDelegate = self
        individualQuizService.quizModelDelegate = self
        tableView.rowHeight = 150.0
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        //custom NavigationBar for all views
        UINavigationBar.appearance().backgroundColor = UIColor.blue
        let titleFont = [ NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 25)! ]
        UINavigationBar.appearance().titleTextAttributes = titleFont
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    //log out
    @IBAction func logOutButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToLogInVC", sender: self)
    }
    //using unwind Seague to LogIn 
    @IBAction func unwindToLogIn(segue:UIStoryboardSegue) { }
    
    //using unwind Seague From QuizCollection View to CourseList
    @IBAction func unwindToCourseList(segue:UIStoryboardSegue) { }
    
    
    private func handleInvalidToken(title: String, message: String){
        let alert = UIAlertController(title:"\(title)", message: "\(message)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "submit", style: .default, handler:{ action in
            self.quizToken = alert.textFields?.first?.text
            guard let token = self.quizToken,
                !token.isEmpty else{
                    self.handleInvalidToken(title: "Invalid Token", message: "please re-enter token")
                    return
            }
            
            self.individualQuizService.loadQuizWithToken(userName: LoginService.userId!, classId: LoginService.quizes[self.selectedCourseIndex!].courseId, quizId: LoginService.quizes[self.selectedCourseIndex!].quizInfo._id, token: token)
        }))
        //        alert.addTextField(configurationHandler: nil)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "please enter token"
            textField.textColor = UIColor.blue
            textField.font = UIFont(name: "AmericanTypewriter", size: 20)
        }
        if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "showQuizDetailsSegue" {
            if let desVC = segue.destination as? QuizVC{
                desVC.tkn = self.quizToken
            }
        }
    }
      override  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return LoginService.quizes.count
        }
        
      override  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as? CourseTVCell
            cell?.decorate(with: LoginService.quizes[indexPath.row])
            return cell!
        }
        
      override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
        {
            selectedCourseIndex = self.tableView.indexPathForSelectedRow?.row
            handleInvalidToken(title: "Quiz Token", message: "") //please enter token
        }
        
    }
    
    extension CourseListTableViewController: QuizModelDelegate{
        
        func dataQuizUpdate() {
            performSegue(withIdentifier: "showQuizDetailsSegue", sender: self)
        }
    }
    
    extension CourseListTableViewController: CheckIsCorrectTokenDelegate{
        func quizNoExist(){
            handleInvalidToken(title: "Invalid Token", message: "please re-enter token")
        }
}

