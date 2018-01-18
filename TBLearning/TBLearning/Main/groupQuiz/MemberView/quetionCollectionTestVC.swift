import UIKit

class quesTestCTV: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let quizModel = IndividualQuizService()
    
    var qzId: String?
    var tkn: String?
    var crsId: String?
    var selectedQuestion: ServiceQuestions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        quizModel.loadQuizWithToken(userName: LoginService.userId!, classId: crsId!, quizId: qzId!, token: tkn!)
    }
}

extension quesTestCTV: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IndividualQuizService.quizWithTokenQuestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "questionCell" , for: indexPath) as! questionCollectionViewCell
        cell.selectedQuestion = IndividualQuizService.quizWithTokenQuestions[indexPath.row]
        return cell
    }
}

