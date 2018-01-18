import UIKit

class answerOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var answerOptionLabel: UILabel!
    @IBOutlet weak var blurViewBg: UIVisualEffectView!
    
    @IBOutlet weak var answerBtn: DesignableButton!
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
    
    func decorate(with answer: ServiceAnswers) {
//        self.pointsPickerView.dataSource = dataPicker
//        self.pointsPickerView.delegate = dataPicker
        answerBtn.setTitle(answer.value, for: .normal)
        self.answerOptionLabel.text = answer.text
    }
}
