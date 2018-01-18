
import UIKit

class answerOptionWithImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var choiceTextView: UITextView!
    @IBOutlet weak var choiceImage: UIImageView!
    @IBOutlet weak var optionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        choiceTextView.isEditable = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func decorate(with answer: ServiceAnswers, withPoints point: Int) {
        choiceTextView.text = String("\n\n" + answer.text)
        optionBtn.setTitle(answer.value, for: .normal)
        //download image from URI, convert and update the scale~
        guard let image = answer.imageUri else{
            Log.info("No Image !")
            return
        }
        choiceImage.downloadedFrom(link: image)
    }
    
}

