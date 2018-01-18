//
//  StatisticVC.swift
//  TBLearning
//
//  Created by Liwei Jiao on 12/8/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import UIKit
import Charts

class StatisticVC: UIViewController {
    @IBOutlet weak var IndividualTotalScoreLabel: UILabel!
    @IBOutlet weak var GroupTotalScoreLabel: UILabel!
    @IBOutlet weak var IndividualChartView: BarChartView!
    @IBOutlet weak var GroupChartView: BarChartView!
    
    var individualScoreArray = [Int16]()
    var groupScoreArray = [Int16]()
    
    let session = DataManager()
    let individualQuizService = IndividualQuizService()
    let groupQuizService = GroupQuizService()
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = session.userPersistence.getUser()
        if !(user!.isLeader){
            let answerChoices = GroupQuizService.groupQuizProgressInfo?.givenAnswers
            let lastQuestionAnswersResult = GroupQuizService.groupQuizProgressInfo?.givenAnswers[(answerChoices?.count)! - 1].submittedAnswers
            let lastAnswer = lastQuestionAnswersResult![(lastQuestionAnswersResult?.count)! - 1].isCorrect
            if GroupQuizService.groupQuizProgressInfo?.totalQuestions == GroupQuizService.groupQuizProgressInfo?.questionsAnswered
                && lastAnswer
                || lastQuestionAnswersResult?.count == 4{
                
                //persist groupQuiz Result
                for answer in answerChoices!{
                    if answer.answeredCorrectly!{
                        let lastAns = answer.submittedAnswers[answer.submittedAnswers.count - 1]
                        let groupQuizAnswerForCD = GroupQuizAnswerForCD(isCorrect: true, points: lastAns.points, questionId: answer.question, quizId: IndividualQuizService.quizId!, value: lastAns.value!)
                        self.session.groupQuizPersistence.saveGroupQuizResult(groupQuiz: groupQuizAnswerForCD, complete: nil)
                    }else{
                        let groupQuizAnswerForCD = GroupQuizAnswerForCD(isCorrect: true, points: 0, questionId: answer.question, quizId: IndividualQuizService.quizId!, value: "")
                        self.session.groupQuizPersistence.saveGroupQuizResult(groupQuiz: groupQuizAnswerForCD, complete: nil)
                    }
                }
        }
        }
            // MARK: - Charts
            self.populateData()
            self.view.backgroundColor = UIColor.black
            GroupTotalScoreLabel.translatesAutoresizingMaskIntoConstraints = false
            IndividualTotalScoreLabel.translatesAutoresizingMaskIntoConstraints = false
            
            IndividualTotalScoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 90).isActive = true
            IndividualTotalScoreLabel.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 110).isActive = true
            IndividualTotalScoreLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            IndividualTotalScoreLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            GroupTotalScoreLabel.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 16).isActive = true
            GroupTotalScoreLabel.bottomAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 32).isActive = true
            GroupTotalScoreLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            GroupTotalScoreLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            
            
            var individualSum: Int16 = 0
            var groupSum: Int16 = 0
            for scores in individualScoreArray {
                individualSum += scores
            }
            
            for scores in groupScoreArray {
                groupSum += scores
            }
            IndividualTotalScoreLabel.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            IndividualTotalScoreLabel.text! = "Individual Quiz Total Score: \(individualSum)"
            IndividualTotalScoreLabel.textAlignment = .center
            GroupTotalScoreLabel.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            GroupTotalScoreLabel.text! = "Group Quiz Total Score: \(groupSum)"
            GroupTotalScoreLabel.textAlignment = .center
            
            barChartUpdate()
            groupChartUpdate()
        
    }
    @IBAction func logoutButtonTapped(_ sender: Any) {
        guard let userInfo = session.userPersistence.getUser() else {
            return
        }
        guard let quizId = userInfo.quizId else{
            print(" no quiz found!! ")
            return
        }
        
        let groupQuizQuestionAnsweredCount = session.groupQuizPersistence.getGroupQuizScore(with: "check", complete: nil).count
        let isQuizResultDeleted = session.individualQuizPersistence.deleteQuiz(for: quizId)
        let isGroupQuizResultDeleted = session.groupQuizPersistence.deleteGroupQuizResult(for: quizId)
        if isQuizResultDeleted && isGroupQuizResultDeleted || groupQuizQuestionAnsweredCount == 0{
            _ = session.userPersistence.updateUserStatus(with: userInfo.userId!, with: "complete")
            individualQuizService.resetIndividualQuizData()
            groupQuizService.resetGroupQuizData()
            performSegue(withIdentifier: "logoutSegue", sender: self)
        }
    }
    
    
    func populateData(){
        individualScoreArray = session.individualQuizPersistence.getIndividualQuizScore(with: "check", complete: nil)
        groupScoreArray = session.groupQuizPersistence.getGroupQuizScore(with: "check", complete: nil)
    }
    
    
        func barChartUpdate() {
            
            var score = [Double]()
            var quesLabel = [String]()
            var index = 1
            for scores in individualScoreArray {
                score.append(Double(scores))
                quesLabel.append("Q\(index)")
                index += 1
            }
            
            
            IndividualChartView.setBarChartData(xValues: quesLabel, yValues: score, label: "Individual Quiz Score")
            IndividualChartView.translatesAutoresizingMaskIntoConstraints = false
            IndividualChartView.topAnchor.constraint(equalTo: IndividualTotalScoreLabel.bottomAnchor).isActive = true
            IndividualChartView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            IndividualChartView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            IndividualChartView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            IndividualChartView.leftAxis.labelCount = 5
            IndividualChartView.rightAxis.labelCount = 5
            IndividualChartView.xAxis.gridLineWidth = 0
            IndividualChartView.chartDescription?.text = ""
            IndividualChartView.doubleTapToZoomEnabled = false
            IndividualChartView.xAxis.labelPosition = .bottom
            IndividualChartView.xAxis.labelCount = quesLabel.count
            IndividualChartView.xAxis.labelTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            IndividualChartView.leftAxis.labelTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            IndividualChartView.rightAxis.labelTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            IndividualChartView.chartDescription?.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            IndividualChartView.data?.setValueTextColor(UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0))
            IndividualChartView.legend.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            IndividualChartView.notifyDataSetChanged()
        }
    
        func groupChartUpdate() {
            var score = [Double]()
            var quesLabel = [String]()
            var index = 1
            for scores in groupScoreArray {
                score.append(Double(scores))
                quesLabel.append("Q\(index)")
                index += 1
            }
            
            GroupChartView.setBarChartData(xValues: quesLabel, yValues: score, label: "Group Quiz Score")
            GroupChartView.translatesAutoresizingMaskIntoConstraints = false
            GroupChartView.topAnchor.constraint(equalTo: GroupTotalScoreLabel.bottomAnchor).isActive = true
            GroupChartView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            GroupChartView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            GroupChartView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            GroupChartView.leftAxis.labelCount = 5
            GroupChartView.rightAxis.labelCount = 5
            
            GroupChartView.xAxis.labelPosition = .bottom
            GroupChartView.doubleTapToZoomEnabled = false
            GroupChartView.xAxis.gridLineWidth = 0
            GroupChartView.chartDescription?.text = ""
            GroupChartView.xAxis.labelCount = quesLabel.count
            GroupChartView.xAxis.labelTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            GroupChartView.leftAxis.labelTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            GroupChartView.rightAxis.labelTextColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            GroupChartView.chartDescription?.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            GroupChartView.data?.setValueTextColor(UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0))
            GroupChartView.legend.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            GroupChartView.notifyDataSetChanged()
        }
    
    
        /*
         // MARK: - Navigation
     
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destinationViewController.
         // Pass the selected object to the new view controller.
         }
         */
    
    }

    extension BarChartView {
        
        private class BarChartFormatter: NSObject, IAxisValueFormatter {
            
            var labels: [String] = []
            
            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                return labels[Int(value)]
            }
            
            init(labels: [String]) {
                super.init()
                self.labels = labels
            }
        }
        
        func setBarChartData(xValues: [String], yValues: [Double], label: String) {
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<yValues.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
            if (label == "Individual Quiz Score") {
                chartDataSet.colors = [UIColor(red:0.58, green:0.07, blue:0.00, alpha:1.0)]
                
            } else {
                chartDataSet.colors = [UIColor(red:0.31, green:0.56, blue:0.00, alpha:1.0)]
            }
            
            let chartData = BarChartData(dataSet: chartDataSet)
            
            chartDescription?.textColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
            
            let chartFormatter = BarChartFormatter(labels: xValues)
            let xAxis = XAxis()
            xAxis.valueFormatter = chartFormatter
            self.xAxis.valueFormatter = xAxis.valueFormatter
            self.data = chartData
        }
}



