import UIKit

protocol updateQuestionBgInColletionViewDelegate: class{
    func updateCollectionView()
}

fileprivate var heightOfHeader : CGFloat = 100

class QuizQuestionVC: UIViewController {
    
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var answersTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nextQuestion: UIButton!
    @IBOutlet weak var pointsView: UIView!
    @IBOutlet weak var timerLabel: UIBarButtonItem!
    


    var timer = Timer()
    var tableViewIndex: Int?
    
    var buttonClickCount: Int = 0
    var goToNextQuestion: Bool = false
    
    var quesAnswers = [SubmittedAnswers]()
    var quesAnswerObj: AnswerResult?

    
    private let quizVC = QuizVC()
    
    let individualQuizService = IndividualQuizService()
    var selectedQuestion: ServiceQuestion?
    // selectedQuestionIndex used for question is complete or not!
    var selectedQuestionIndex: Int?
    var questionNumber: Int?
    var endOfQuestions: Bool?
    var qzId: String?
    var tkn: String?
    var crsId: String?
    
    let session = DataManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let text = selectedQuestion?.text else{
            handleLastQuestion()
            return
        }
        questionTextView.text = "\n"+text
        questionTextView.layer.cornerRadius = 10
        answersTableView.dataSource = self
        answersTableView.delegate = self
        answersTableView.rowHeight = UITableViewAutomaticDimension
        answersTableView.estimatedRowHeight = 300
        
        if(questionNumber == (IndividualQuizService.quizWithTokenQuestions.count - 1)){
            endOfQuestions = true
        }
        
        guard let _ = endOfQuestions else {
            self.navBar.topItem?.title = selectedQuestion!.title + " "
            return
        }

        self.navBar.topItem?.title = (selectedQuestion?.title)! + " "
        nextQuestion.setTitle("Last", for: .normal)
        timerLabel.isEnabled = false
        handleLastQuestion()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let nc = NotificationCenter.default
        let timerNotification = Notification.Name(rawValue:"timerNotification")
        nc.addObserver(forName: timerNotification, object:nil, queue:nil, using: updateTimerLabel)
    }
    
    @objc func handleTimeOut(){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let newTodoAsJSON = try QuizPayLoad(quizId: IndividualQuizService.quizId!, questions: IndividualQuizService.postQuizQuestions ).encode()
            print(String(data: newTodoAsJSON, encoding: .utf8) ?? "no body data")
            individualQuizService.loadQuizResult(userId: LoginService.userId!, courseId: IndividualQuizService.quizCourseId!, sessionId: IndividualQuizService.quizSessionId!, quiz: newTodoAsJSON)
        } catch {
            print(error)
        }
    }
    
    func updateTimerLabel(not: Notification) -> Void{
        
        guard let userInfo = not.userInfo,
            let message  = userInfo["timeString"] as? String else {
                print("No userInfo found in notification")
                return
        }

        self.timerLabel.title = message
    }
    //LogOutUnwindSegue
    @IBAction func LogOutNavBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "LogOutUnwindSegue", sender: self)
        //reset IndividualQuizService static vars****
        individualQuizService.resetIndividualQuizData()
    }
    
    @IBAction func unwindToLogIn(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func BackToQuizCollectionViewButtonTapped(_ sender: Any){
        performSegue(withIdentifier: "unwindSegueToQuizCollectionView", sender: self)
    }
    
    
    
    @IBAction func NextQuestionButtonTapped(_ sender: UIButton) {
        if let _ = self.endOfQuestions{
            //*********** need check last question saved or not
            if(buttonClickCount == 0){
                self.skipQuestionAlert()
                return
            }else if(buttonClickCount < Int(selectedQuestion!.pointsPossible)){
                self.answerNotFullFilledAlert()
                return
            }else{
                self.persistPointsIntoDataBase()
                self.persistAnswers()
                IndividualQuizService.quizIsComplete[IndividualQuizService.quizIsComplete.count - 1] = "completed"
                guard let question = self.selectedQuestion else{
                    self.performSegue(withIdentifier: "unwindSegueToQuizCollectionView", sender: self)
                    return
                }
                self.session.individualQuizPersistence.updateQuestionStatus(questionId: question.id, status: "completed", complete: nil)
                self.handleLastQuestion()
            }
            
        }else{
            if(buttonClickCount == 0){
                self.skipQuestionAlert()
            }else if(buttonClickCount < Int(selectedQuestion!.pointsPossible)){
                self.answerNotFullFilledAlert()
            }else{
                self.persistPointsIntoDataBase()
                IndividualQuizService.quizIsComplete[self.selectedQuestionIndex!] = "completed"
                self.session.individualQuizPersistence.updateQuestionStatus(questionId: (self.selectedQuestion?.id)!, status: "completed", complete: nil)
                self.persistAnswers()
            }
        }
        
    }
    
    @IBAction func clearPointsViewButton(_ sender: UIButton) {
        buttonClickCount = 0
        quesAnswers.removeAll()
        for view in self.pointsView.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    //check is current question is lastquestion,
    //  check all the questions complete
    //  alert
    private func handleLastQuestion(){
//        self.quizPersistance.updateQuestionStatus(questionId: question.id, status: "completed", complete: nil)
        self.performSegue(withIdentifier: "unwindSegueToQuizCollectionView", sender: self)
    }

    private func persistPointsIntoDataBase(){
        var pointsArray: [Int16] = []
        let pointsForA = quesAnswers.filter({$0.value == "A"})
        if pointsForA.isEmpty{
            pointsArray.append(0)
        }else{
            pointsArray.append(pointsForA[0].allocatedPoints)
        }
        let pointsForB = quesAnswers.filter({$0.value == "B"})
        if pointsForB.isEmpty{
            pointsArray.append(0)
        }else{
            pointsArray.append(pointsForB[0].allocatedPoints)
        }
        let pointsForC = quesAnswers.filter({$0.value == "C"})
        if pointsForC.isEmpty{
            pointsArray.append(0)
        }else{
            pointsArray.append(pointsForC[0].allocatedPoints)
        }
        let pointsForD = quesAnswers.filter({$0.value == "D"})
        if pointsForD.isEmpty{
            pointsArray.append(0)
        }else{
            pointsArray.append(pointsForD[0].allocatedPoints)
        }
        
        session.individualQuizPersistence.updateQuestionAnswer(questionId: (self.selectedQuestion?.id)!, answerArray: pointsArray, complete: nil)
        return
    }
    
    
    private func skipQuestionAlert(){
        let alert = UIAlertController(title:"Skip", message: "Do you want to skip this question?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            ////*********************check end of questions
            if let _ = self.endOfQuestions{
                IndividualQuizService.quizIsComplete[self.selectedQuestionIndex!] = "inComplete"
                self.session.individualQuizPersistence.updateQuestionStatus(questionId: (self.selectedQuestion?.id)!, status: "inComplete", complete: nil)
                self.performSegue(withIdentifier: "unwindSegueToQuizCollectionView", sender: self)
            }else{
                self.performSegue(withIdentifier: "nextQuestionSegue", sender: self)
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler:{ action in
            guard let index = self.selectedQuestionIndex else {
                return
            }
            if index < IndividualQuizService.quizIsComplete.count{
                IndividualQuizService.quizIsComplete[self.selectedQuestionIndex!] = "inComplete"
                self.session.individualQuizPersistence.updateQuestionStatus(questionId: (self.selectedQuestion?.id)!, status: "inComplete", complete: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func answerNotFullFilledAlert(){
        let alert = UIAlertController(title:"Points Not Fullfilled", message: "You still have points left, still want to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{ action in
            if let _ = self.endOfQuestions{
                self.handleLastQuestion()
            }else{
                self.performSegue(withIdentifier: "nextQuestionSegue", sender: self)
                IndividualQuizService.quizIsComplete[self.selectedQuestionIndex!] = "notFullFilled"
                self.session.individualQuizPersistence.updateQuestionStatus(questionId: (self.selectedQuestion?.id)!, status: "notFullFilled", complete: nil)
                self.persistAnswers()
                self.persistPointsIntoDataBase()
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .default, handler:{ action in
            IndividualQuizService.quizIsComplete[self.selectedQuestionIndex!] = "notFullFilled"
            self.session.individualQuizPersistence.updateQuestionStatus(questionId: (self.selectedQuestion?.id)!, status: "notFullFilled", complete: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //need handling modify~~~ back from collection view
    private func persistAnswers(){
        
        var questionExisted = false
        let _ = IndividualQuizService.postQuizQuestions.filter { (question) -> Bool in
            guard let id = selectedQuestion?.id else {return true}
            if question.quesId == id{
                
                questionExisted = true
                return true
            }else {
                
                return false
            }
        }
        if questionExisted{
            for(index, question) in IndividualQuizService.postQuizQuestions.enumerated(){
                if(question.quesId == (selectedQuestion?.id)!){
                    IndividualQuizService.postQuizQuestions[index].submittedAnswers = self.quesAnswers
                }
            }
        }else{
            IndividualQuizService.postQuizQuestions.append(QuestionPayLoad(quesId: (selectedQuestion?.id)!, submittedAnswers: quesAnswers))
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextQuestionSegue"{
            let destVC = segue.destination as! QuizQuestionVC
            guard (questionNumber! + 2) < IndividualQuizService.quizWithTokenQuestions.count else {
                destVC.endOfQuestions = true
                if((questionNumber! + 1) == (IndividualQuizService.quizWithTokenQuestions.count)){
                    destVC.selectedQuestion = nil
                    return
                }
                destVC.selectedQuestion = IndividualQuizService.quizWithTokenQuestions[questionNumber!+1]
                destVC.questionNumber = questionNumber!+1
                
                return
            }
            destVC.selectedQuestion = IndividualQuizService.quizWithTokenQuestions[questionNumber!+1]
            destVC.questionNumber = questionNumber!+1
            destVC.selectedQuestionIndex = selectedQuestionIndex! + 1
        } else if segue.identifier == "unwindSegueToQuizCollectionView" {
            if let destVC = segue.destination as? QuizVC{
                //if all questions completed, after back to quizCollectionViewController,
                //   we want to show and enable the submitQuiz button
                let InCompleteQuestions = session.individualQuizPersistence.getCompleteQuestionsByStatus(with: "inComplete", complete: nil)
                guard let _ = self.endOfQuestions
                    ,InCompleteQuestions.count == 0 else {
                        return
                }
                destVC.submitQuizButton.isHidden = false
                destVC.submitQuizButton.isEnabled = true
            }
        }
    }
    
    //handle table view cell long press
    @objc func buttonPressDown(sender: UIButton){
        tableViewIndex = sender.tag
        timer = Timer.scheduledTimer(timeInterval: 0.19, target: self, selector: #selector(self.UpdatePoints), userInfo: nil, repeats: true)
        
    }
    
    @objc func UpdatePoints(){
        let numberOfAnswers = selectedQuestion?.availableAnswers?.count
        if(buttonClickCount <= (numberOfAnswers! - 1)){
            if let answerView = Bundle.main.loadNibNamed("choiceView", owner: self, options: nil)?.first as? AnswerOptionButtonView{
                var testRect: CGRect = answerView.frame
                testRect.origin.x = 6/*self.targetViewHalfX!*/
                    + (self.pointsView.frame.width / CGFloat(numberOfAnswers!)) * CGFloat(buttonClickCount)
                testRect.origin.y = self.pointsView.frame.origin.y + 2
                testRect.size.width = self.pointsView.frame.width / CGFloat(numberOfAnswers!) - 10
                testRect.size.height = self.pointsView.frame.height - 5
                answerView.frame.origin.x = testRect.origin.x
                answerView.frame = testRect
                answerView.optionButtonLabel.text = selectedQuestion?.availableAnswers![self.tableViewIndex!].value
                //                collect["\(data[indexPath.row])"]! += 1
                answerView.optionButtonBlurBg.layer.cornerRadius = 10
                answerView.optionButtonBlurBg.clipsToBounds = true
                answerView.optionButtonLabel.layer.cornerRadius = 10
                answerView.optionButtonLabel.clipsToBounds = true
                pointsView.addSubview(answerView)
                buttonClickCount += 1
                
                //save quesAnswer into quesAnswers array
                for (index,answer) in quesAnswers.enumerated(){
                    if(answerView.optionButtonLabel.text == answer.value){
                        quesAnswers[index].allocatedPoints += 1
                        return
                    }
                }
                quesAnswers.append(SubmittedAnswers(value: answerView.optionButtonLabel.text!, allocatedPoints: 1))
                Log.info(quesAnswers)
                
                
            }
        } else {
            buttonClickCount = 0
            //clear quesAnswers array
            quesAnswers.removeAll()
            for view in self.pointsView.subviews {
                view.removeFromSuperview()
            }
        }
        
    }
    //handle table view cell btn release
    @objc func buttonRelease(sender: UIButton) {
        timer.invalidate()
    }
}



extension QuizQuestionVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedQuestion?.availableAnswers?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let _ = (selectedQuestion?.availableAnswers![indexPath.row])!.imageUri{
            let cell = Bundle.main.loadNibNamed("answerOptionWithImageTableViewCell", owner: self, options: nil)?.first as? answerOptionWithImageTableViewCell
        cell?.decorate(with: (selectedQuestion?.availableAnswers![indexPath.row])!, withPoints: Int((selectedQuestion?.pointsPossible)!))
        cell?.optionBtn.tag = indexPath.row
        cell?.optionBtn.addTarget(self, action: #selector(self.buttonPressDown(sender:)), for: .touchDown)
        cell?.optionBtn.addTarget(self, action: #selector(self.buttonRelease(sender:)), for: [.touchUpInside, .touchUpOutside])
        
        
            return cell!
        
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerTableViewCell", for: indexPath) as? AnswerTableViewCell
            cell?.decorate(with: (selectedQuestion?.availableAnswers![indexPath.row])!, withPoints: Int((selectedQuestion?.pointsPossible)!))
            cell?.optionBtn.tag = indexPath.row
            cell?.optionBtn.addTarget(self, action: #selector(self.buttonPressDown(sender:)), for: .touchDown)
            cell?.optionBtn.addTarget(self, action: #selector(self.buttonRelease(sender:)), for: [.touchUpInside, .touchUpOutside])
            return cell!

        }
        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension QuizQuestionVC: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numberOfAnswers = selectedQuestion?.availableAnswers?.count
        if(buttonClickCount <= (numberOfAnswers! - 1)){
            if let answerView = Bundle.main.loadNibNamed("choiceView", owner: self, options: nil)?.first as? AnswerOptionButtonView{
                var testRect: CGRect = answerView.frame
                testRect.origin.x = 6/*self.targetViewHalfX!*/
                    + (self.pointsView.frame.width / CGFloat(numberOfAnswers!)) * CGFloat(buttonClickCount)
                testRect.origin.y = self.pointsView.frame.origin.y + 2
                testRect.size.width = self.pointsView.frame.width / CGFloat(numberOfAnswers!) - 10
                testRect.size.height = self.pointsView.frame.height - 5
                answerView.frame.origin.x = testRect.origin.x
                answerView.frame = testRect
                answerView.optionButtonLabel.text = selectedQuestion?.availableAnswers![indexPath.row].value
                //                collect["\(data[indexPath.row])"]! += 1
                answerView.optionButtonBlurBg.layer.cornerRadius = 10
                answerView.optionButtonBlurBg.clipsToBounds = true
                answerView.optionButtonLabel.layer.cornerRadius = 10
                answerView.optionButtonLabel.clipsToBounds = true
                pointsView.addSubview(answerView)
                buttonClickCount += 1
                
                //save quesAnswer into quesAnswers array
                for (index,answer) in quesAnswers.enumerated(){
                    if(answerView.optionButtonLabel.text == answer.value){
                        quesAnswers[index].allocatedPoints += 1
                        return
                    }
                }
                
                quesAnswers.append(SubmittedAnswers(value: answerView.optionButtonLabel.text!, allocatedPoints: 1))
                Log.info(quesAnswers)
                
                
            }
        } else {
            buttonClickCount = 0
            //clear quesAnswers array
            quesAnswers.removeAll()
            for view in self.pointsView.subviews {
                view.removeFromSuperview()
            }
        }
        
 
    }
    
    
}






