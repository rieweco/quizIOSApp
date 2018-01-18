	//
//  groupQuizVC.swift
//  TBLearning
//
//  Created by Liwei Jiao on 11/23/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import UIKit

class groupQuizVC: UIViewController {

    @IBOutlet weak var groupQuestionTextView: UITextView!
    @IBOutlet weak var groupQuizQuestionAnswerOptionTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var fakeBtn: UIButton!
    @IBOutlet weak var pointsBarItem: UIBarButtonItem!
    
    
    let session = DataManager()
    //create static var in groupquiz service to hold questionIndex
    var questionIndex: Int = 0
    var isGroupQuizComplete: Bool = false
    
    //selected cell indexPath
    var selectedCellIndexPath: IndexPath?
    
    var groupQuizService = GroupQuizService()
    override func viewDidLoad() {
        super.viewDidLoad()
        groupQuizQuestionAnswerOptionTableView.dataSource = self
        groupQuizQuestionAnswerOptionTableView.delegate = self
        groupQuizService.groupQuizServiceDelegate = self
        questionIndex = GroupQuizService.groupQuizQuestionIndex
        pointsBarItem.title = " 4 "
        if isGroupQuizComplete{
            groupQuestionTextView.text = IndividualQuizService.quizWithTokenQuestions[questionIndex].text
            self.navBar.topItem?.title =
                IndividualQuizService.quizWithTokenQuestions[questionIndex].title
            
            //create fake button for creating a seague for gesture~~~
            self.fakeBtn.isHidden = true
            self.fakeBtn.isEnabled = false
            //swip guesture
            //key to make swip work
            groupQuestionTextView.isUserInteractionEnabled = false
        }else{
            groupQuestionTextView.text = IndividualQuizService.quizWithTokenQuestions[questionIndex].text
            self.navBar.topItem?.title =
                IndividualQuizService.quizWithTokenQuestions[questionIndex].title
            
            //create fake button for creating a seague for gesture~~~
            self.fakeBtn.isHidden = true
            self.fakeBtn.isEnabled = false
            //swip guesture
            //key to make swip work
            groupQuestionTextView.isUserInteractionEnabled = true
            let leftSwipOnQuesitonLabel = UISwipeGestureRecognizer(target: self, action: #selector(swipAction(swipe:)))
            leftSwipOnQuesitonLabel.direction = UISwipeGestureRecognizerDirection.left
            self.groupQuestionTextView.addGestureRecognizer(leftSwipOnQuesitonLabel)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let nc = NotificationCenter.default
        let timerNotification = Notification.Name(rawValue:"groupQuizQuestionPointsRemain")
        nc.addObserver(forName: timerNotification, object:nil, queue:nil, using: updatePointsLabel)
    }
    
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    func updatePointsLabel(not: Notification) -> Void{
        
        guard let userInfo = not.userInfo,
            let points  = userInfo["pointLeft"] as? String else {
                print("No userInfo found in notification")
                return
        }
        //
        self.pointsBarItem.title = String(describing: points)
    }
}

extension groupQuizVC{
    private func handleLastQuestion(){
        self.performSegue(withIdentifier: "doneGroupQuizSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "nextGroupQuestionSegue"{
            if let desVC = segue.destination as? groupQuizVC{
                guard (GroupQuizService.groupQuizQuestionIndex + 2) < IndividualQuizService.quizWithTokenQuestions.count else {
                    desVC.isGroupQuizComplete = true
                    if((GroupQuizService.groupQuizQuestionIndex + 1) == (IndividualQuizService.quizWithTokenQuestions.count)){
                        return
                    }
                    GroupQuizService.groupQuizQuestionIndex += 1
                    return
                }
                GroupQuizService.groupQuizQuestionIndex += 1
            }
            
        }
    }
    
    @objc func swipAction(swipe:UISwipeGestureRecognizer){
        switch swipe.direction.rawValue {
        case 2:
            self.performSegue(withIdentifier: "nextGroupQuestionSegue", sender: self)
        default:
            break
        }
    }
    

}

extension groupQuizVC: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let answerOption = IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![indexPath.row]
        let questionId = IndividualQuizService.quizWithTokenQuestions[questionIndex].id
        if let _ = answerOption.imageUri{
            let cell = Bundle.main.loadNibNamed("groupQuizWithImageTableViewCell", owner: self, options: nil)?.first as? groupQuizWithImageTableViewCell
            cell?.decorate(with: answerOption, for: questionId)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "unknown"), for: .normal)
            cell?.delegate = self
            return cell!
            
        }else{
            let cell = Bundle.main.loadNibNamed("groupQuizTableViewCell", owner: self, options: nil)?.first as? groupQuizTableViewCell
            cell?.decorate(with: (IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![indexPath.row]), for: IndividualQuizService.quizWithTokenQuestions[questionIndex].id)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "unknown"), for: .normal)
            cell?.delegate = self
            return cell!
            
        }
    }
}

extension groupQuizVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

extension groupQuizVC: groupQuizTableViewCellDelegate{
    func groupQuizTVCellCheckAnswerBtnTapped(_ sender: groupQuizTableViewCell) {
        guard let tappedIndexPath = groupQuizQuestionAnswerOptionTableView.indexPath(for: sender) else { return }
        //save the selected tableview cell indexPath
        self.selectedCellIndexPath = tappedIndexPath
        let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: tappedIndexPath) as? groupQuizTableViewCell
        do {
            let groupQuizAnswer = try GroupQuizPostBody(question_id: (cell?.questionId!)!,answerValue: (cell?.questionAnswerOption?.value)!).encode()
            Log.info(groupQuizAnswer)
            print(String(data: groupQuizAnswer, encoding: .utf8) ?? "no body data")
            groupQuizService.loadGroupQuizResult(quizId: IndividualQuizService.quizId!, groupId: GroupQuizService.grpId!, sessionId: IndividualQuizService.quizSessionId!, groupQuizData: groupQuizAnswer)
        } catch {
            print(error)
        }
    }
}

extension groupQuizVC: groupQuizWithImageTableViewCellDelegate{
    func groupQuizTVCellCheckAnswerBtnTapped(_ sender: groupQuizWithImageTableViewCell) {
        guard let tappedIndexPath = groupQuizQuestionAnswerOptionTableView.indexPath(for: sender) else { return }
        //save the selected tableview cell indexPath
        self.selectedCellIndexPath = tappedIndexPath
        let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: tappedIndexPath) as? groupQuizWithImageTableViewCell
        do {
            let groupQuizAnswer = try GroupQuizPostBody(question_id: (cell?.questionId)!,answerValue: (cell?.questionAnswerOption?.value)!).encode()
            Log.info(groupQuizAnswer)
            print(String(data: groupQuizAnswer, encoding: .utf8) ?? "no body data")
            groupQuizService.loadGroupQuizResult(quizId: IndividualQuizService.quizId!, groupId: GroupQuizService.grpId!, sessionId: IndividualQuizService.quizSessionId!, groupQuizData: groupQuizAnswer)
        } catch {
            print(error)
        }
    }
}

extension groupQuizVC: GroupQuizServiceDelegate{
    func answerPassUIUpdate(){
        let answerOption = IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![self.selectedCellIndexPath!.row]
        if let _ = answerOption.imageUri{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizWithImageTableViewCell
            cell?.answerOptionTextView.backgroundColor = UIColor(red: 0, green: 254/255, blue: 138/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "true"), for: .normal)
            self.handleInvalidToken(title: "Correct ", message: "Pass")
        }else{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizTableViewCell
            cell?.answerChoiceLabel.backgroundColor = UIColor(red: 0, green: 254/255, blue: 138/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "true"), for: .normal)
            self.handleInvalidToken(title: "Correct ", message: "Pass")
        }
    }
    
    //
    
    func answerFailedUIUpdate(){
        let answerOption = IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![self.selectedCellIndexPath!.row]
        if let _ = answerOption.imageUri{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizWithImageTableViewCell
            cell?.answerOptionTextView.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "false"), for: .normal)
//            self.handleWrongAnswer(title: "Wrong", message: "You wasted a chance!")
        }else{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizTableViewCell
            cell?.answerChoiceLabel.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "false"), for: .normal)
//            self.handleWrongAnswer(title: "Wrong", message: "You wasted a chance!")
        }

    }
    
    func duplicateAnswer(){
        let answerOption = IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![self.selectedCellIndexPath!.row]
        if let _ = answerOption.imageUri{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizWithImageTableViewCell
            cell?.answerOptionTextView.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "false"), for: .normal)
            self.handleWrongAnswer(title: "Duplicate", message: "Invalid choice, duplicate answer!")
            
        }else{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizTableViewCell
            cell?.answerChoiceLabel.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "false"), for: .normal)
            self.handleWrongAnswer(title: "Duplicate", message: "Invalid choice, duplicate answer!")
        }

    }
    
    func invalidPostCall(){
        let answerOption = IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![self.selectedCellIndexPath!.row]
        if let _ = answerOption.imageUri{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizWithImageTableViewCell
            cell?.answerOptionTextView.backgroundColor = UIColor.purple
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "unknown"), for: .normal)
            self.handleWrongAnswer(title: "Failed", message: "This Question has submitted")
            
        }else{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizTableViewCell
            cell?.answerChoiceLabel.backgroundColor = UIColor.purple
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "unknown"), for: .normal)
            //        AlertController.showAlert(self, title: "Failed  ", message: "You can't submit any more")
            self.handleInvalidToken(title: "Failed", message: "This Question has submitted")
        }
        

    }
    func noPointsLeft(){
        let answerOption = IndividualQuizService.quizWithTokenQuestions[questionIndex].availableAnswers![self.selectedCellIndexPath!.row]
        if let _ = answerOption.imageUri{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizWithImageTableViewCell
            cell?.answerOptionTextView.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "false"), for: .normal)
            self.handleWrongAnswer(title: "0 Points", message: "No points remained~")
            self.pointsBarItem.title = String(describing: 0)
            
        }else{
            let cell = groupQuizQuestionAnswerOptionTableView.cellForRow(at: self.selectedCellIndexPath!) as? groupQuizTableViewCell
            cell?.answerChoiceLabel.backgroundColor = UIColor(red: 205/255, green:72/255, blue: 64/255, alpha: 1)
            cell?.answerOptionBtn.setBackgroundImage(UIImage(named: "false"), for: .normal)
            self.handleInvalidToken(title: "0 Points", message: "No points remained~")
            self.pointsBarItem.title = String(describing: 0)
        }
    }
}

extension groupQuizVC{
    private func handleInvalidToken(title: String, message: String){
        let alert = UIAlertController(title:"\(title)", message: "\(message)", preferredStyle: .alert)
        alert.view.layer.cornerRadius = 25
        
        alert.addAction(UIAlertAction(title: "Next Question", style: .default, handler:{ action in
            if self.isGroupQuizComplete{
                self.handleLastQuestion()
            }else{
                
                self.performSegue(withIdentifier: "nextGroupQuestionSegue", sender: self)
            }
        }))

        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func handleWrongAnswer(title: String, message: String){
        let alert = UIAlertController(title:"\(title)", message: "\(message)", preferredStyle: .alert)
        alert.view.layer.cornerRadius = 25
        alert.addAction(UIAlertAction(title: "Try it again", style: .default, handler:{ action in
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
}






