import UIKit

protocol groupQuizTableViewCellDelegate : class {
    func groupQuizTVCellCheckAnswerBtnTapped(_ sender: groupQuizTableViewCell)
}

class groupQuizTableViewCell: UITableViewCell {
    @IBOutlet weak var answerChoiceLabel: UILabel!
    @IBOutlet weak var answerOptionBtn: UIButton!
    weak var delegate: groupQuizTableViewCellDelegate?
    private(set) var questionId: String?{
        didSet{
            
        }
    }
    
    private(set) var questionAnswerOption: ServiceAnswers?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.answerChoiceLabel.layer.cornerRadius  = 20
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func answerOptoinBtnTapped(_ sender: UIButton) {
        delegate?.groupQuizTVCellCheckAnswerBtnTapped(self)

    }
    
    func decorate(with answerOption: ServiceAnswers, for questionId: String){
        self.questionAnswerOption = answerOption
        self.answerChoiceLabel.text = answerOption.text
        self.questionId = questionId
    }
    
}
