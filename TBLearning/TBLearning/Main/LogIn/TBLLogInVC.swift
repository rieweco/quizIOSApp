import UIKit

class TBLLogInVC: UIViewController {
    
    @IBOutlet weak var bgview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToLogIn(segue:UIStoryboardSegue) { }
    @IBAction func LogInToQuizVC(segue:UIStoryboardSegue) { }
    @IBAction func LogInToQuestionVC(segue:UIStoryboardSegue) { }
    @IBAction func unwindToLogInFromGroupQuiz(segue:UIStoryboardSegue) { }
    @IBAction func unwindToLogInFromStatistic(segue:UIStoryboardSegue) { }
    @IBAction func unwindToLogInFromMemberView(segue:UIStoryboardSegue) { }
    
}
