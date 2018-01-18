import UIKit

class answerOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var answerOptionLabel: UILabel!
    @IBOutlet weak var blurViewBg: UIVisualEffectView!
    
    @IBOutlet weak var answerBtn: DesignableButton!
    //add more feature
//    @IBOutlet weak var pointsPickerView: UIPickerView!
    
//    var dataPicker: pointsPickerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        blurViewBg.layer.cornerRadius = 20
        blurViewBg.layer.masksToBounds = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func decorate(with answer: ServiceAnswers, with givenAnswer: [SubmitAnswer]) {
        if givenAnswer.count > 0{
            for ans in givenAnswer{
                if answer.value == ans.value{
                    if ans.isCorrect{
                        self.blurViewBg.backgroundColor = UIColor.green
                    }else{
                        self.blurViewBg.backgroundColor = UIColor.red
                    }
                }
            }
        }
        answerBtn.setTitle(answer.value, for: .normal)
        self.answerOptionLabel.text = answer.text
    }
}
