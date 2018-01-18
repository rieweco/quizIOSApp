import UIKit

class questionCollectionViewCell: UICollectionViewCell {
    static var answerDic: [(text: String, value: Int)] = []
    static var maxAnswerPoints: Int = 0
    
    var buttonClickCount: Int = 0
    //    var targetViewHalfX: CGFloat?
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var pointsView: UILabel!
    
    override func awakeFromNib() {
        self.optionsTableView.layer.cornerRadius = 10
    }
    
    var selectedQuestion:ServiceQuestion? = nil {
        didSet{
            optionsTableView.dataSource = self
            optionsTableView.rowHeight = 100
            questionText.text = selectedQuestion!.text
            
        }
    }
    var selectedQuestionAnswer: AnswerResult?
}

extension questionCollectionViewCell: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedQuestion?.availableAnswers!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("answerOptionTableViewCell", owner: self, options: nil)?.first as! answerOptionTableViewCell
        guard let answer = selectedQuestionAnswer?.submittedAnswers else{
            cell.decorate(with: (selectedQuestion?.availableAnswers![indexPath.row])!, with:[])
            return cell
        }
        let points = answer[answer.count - 1].points
        Log.info(points)
        self.pointsView.text = String(describing: answer[answer.count - 1].points)
        cell.decorate(with: (selectedQuestion?.availableAnswers![indexPath.row])!, with:answer)
        return cell
    }
    //here worth thousand dollar prepareForReuse is the key to reuse the collectionViewCell
    override func prepareForReuse() {
        super.prepareForReuse()
        self.optionsTableView.reloadData()
    }
    
    
}
extension questionCollectionViewCell: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numberOfAnswers = selectedQuestion?.availableAnswers?.count
        if(buttonClickCount <= (numberOfAnswers! - 1)){
            if let answerView = Bundle.main.loadNibNamed("choiceView", owner: self, options: nil)?.first as? AnswerOptionButtonView{
                var testRect: CGRect = answerView.frame
                testRect.origin.x =  5/*self.targetViewHalfX!*/
                    + (self.pointsView.frame.width / CGFloat(numberOfAnswers!)) * CGFloat(buttonClickCount)
                testRect.size.width = self.pointsView.frame.width / CGFloat(numberOfAnswers!) - 10
                testRect.size.height = self.pointsView.frame.height - 5
                answerView.frame.origin.x = testRect.origin.x
                answerView.frame = testRect
                answerView.optionButtonLabel.text = selectedQuestion?.availableAnswers![indexPath.row].value
                pointsView.addSubview(answerView)
                buttonClickCount += 1
            }
            
        } else {
            buttonClickCount = 0
            for view in self.pointsView.subviews {
                view.removeFromSuperview()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
