import UIKit

class quesTestCTV: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var initialLabel: UILabel!
    
    var isQuizComplete: Bool = false
    
    let groupQuizService = GroupQuizService()
    let quizModel = IndividualQuizService()
    let session = DataManager()
    var answeredGroupQuestions: [ServiceQuestion]? = []{
        didSet {
            self.view.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
            // whenever the imageArray changes, reload the imagesList
            if (answeredGroupQuestions?.count)! > 1{
                    self.addNewQuestion()
            }else {
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        initialLabel.text = "Waiting for leader~~~"
        
        groupQuizService.groupQuizProgressDelegate = self
        groupQuizService.loadGroupQuizProgress(quizId: IndividualQuizService.quizId!, groupId: GroupQuizService.grpId!, sessionId: IndividualQuizService.quizSessionId!)
        //update User Status to in groupQuizProgress
        _ = session.userPersistence.updateUserStatus(with: LoginService.userId!, with: "inGroupQuiz")
    }
    override func viewWillAppear(_ animated: Bool) {
        if (answeredGroupQuestions?.count)! > 0{
            let section = 0
            let item = collectionView.numberOfItems(inSection: section) - 1
            let lastIndexPath = IndexPath(item: item, section: section)
            collectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    func repeatGroupProgressNetworkCall(){
            groupQuizService.loadGroupQuizProgress(quizId: IndividualQuizService.quizId!, groupId: GroupQuizService.grpId!, sessionId: IndividualQuizService.quizSessionId!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollSize: CGSize? = collectionView?.frame.size
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        let inset: UIEdgeInsets? = layout?.sectionInset
        layout?.itemSize = CGSize(width: (scrollSize?.width)! - (inset?.left)! - (inset?.right)!, height: (scrollSize?.height)! - (inset?.top)! - (inset?.bottom)!)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func updateCollectionView(){
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func addNewQuestion(){
        let insertedIndexPath = IndexPath(item: ((self.answeredGroupQuestions?.count)! - 1) , section: 0)
        collectionView.insertItems(at: [insertedIndexPath])
    }
    
    //if current Collection Cell is the last Question in the Quiz
    // and if it's completed~
    func handleLastQuestionPage(){
        let answerChoices = GroupQuizService.groupQuizProgressInfo?.givenAnswers
        let lastQuestionAnswer = GroupQuizService.groupQuizProgressInfo?.givenAnswers[(answerChoices?.count)! - 1]
        let lastQuestionAnswersResult = lastQuestionAnswer?.submittedAnswers
        let lastQuestion = IndividualQuizService.postQuizQuestions[IndividualQuizService.postQuizQuestions.count - 1]
        
        let lastAnswer = lastQuestionAnswersResult![(lastQuestionAnswersResult?.count)! - 1].isCorrect
        if GroupQuizService.groupQuizProgressInfo?.totalQuestions == GroupQuizService.groupQuizProgressInfo?.questionsAnswered
            && lastAnswer || lastQuestionAnswer?.question == lastQuestion.quesId && lastQuestionAnswersResult?.count == 4{
            isQuizComplete = true
            performSegue(withIdentifier: "showSummarySegue", sender: self)
        }
    }
    
}

extension quesTestCTV: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Log.info(self.answeredGroupQuestions?.count)
        guard let groupQuestionAnswered = self.answeredGroupQuestions else {return 0}
        return groupQuestionAnswered.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "questionCell" , for: indexPath) as! questionCollectionViewCell
        Log.info(indexPath.row)
        cell.selectedQuestion = self.answeredGroupQuestions?[indexPath.row]
        
        
        guard let answerResults = GroupQuizService.groupQuizProgressInfo,
            indexPath.row <=  (answerResults.givenAnswers.count - 1)
             else {
            return cell
        }
        cell.selectedQuestionAnswer = answerResults.givenAnswers[indexPath.row]
        return cell
    }
}

extension quesTestCTV: QuizModelDelegate{
    func dataQuizUpdate() {
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension quesTestCTV: CheckIsCorrectTokenDelegate{
    func quizNoExist() {
    }
}

extension quesTestCTV: UIScrollViewDelegate, UICollectionViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //add more feature
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //add more feature
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidth //CGFloat
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidth - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
        

    }

}

extension quesTestCTV: GroupQuizProgressDelegate{
    func updateGroupQuizOnSameQuestion() {
        let insertedIndexPath = IndexPath(item: ((self.answeredGroupQuestions?.count)! - 1) , section: 0)
        self.collectionView.reloadItems(at: [insertedIndexPath])
        self.handleLastQuestionPage()
        if !self.isQuizComplete{
            self.repeatGroupProgressNetworkCall()
        }
    }
    
    func updateGroupQuizProgressData() {
        guard let groupQuizProgressFeedback = GroupQuizService.groupQuizProgressInfo
            else{
                return
        }
        self.answeredGroupQuestions!.append( IndividualQuizService.quizWithTokenQuestions[groupQuizProgressFeedback.givenAnswers.count - 1])
        let insertedIndexPath = IndexPath(item: (GroupQuizService.groupQuizSubmittedAnswers.count - 1), section: 0)
        collectionView.reloadItems(at: [insertedIndexPath])
        self.handleLastQuestionPage()
        if !self.isQuizComplete{
            self.repeatGroupProgressNetworkCall()
        }
    }
    
    func updateGroupQuizProgressFailed(){
        if !self.isQuizComplete{
            self.repeatGroupProgressNetworkCall()
        }
    }
}

