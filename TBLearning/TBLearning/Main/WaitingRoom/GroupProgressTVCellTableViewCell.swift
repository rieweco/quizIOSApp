import UIKit

class GroupProgressTVCellTableViewCell: UITableViewCell {
    @IBOutlet weak var memberBgView: UIView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var memberVIew: customLabelView!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(red:240, green:240, blue:240, alpha: 1.0)
        memberBgView.layer.masksToBounds = true
        memberBgView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        memberBgView.layer.shadowOffset = CGSize(width: 10, height: 10)
        memberBgView.layer.shadowOpacity = 0.8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI(){
 
        
    }
    func decorate(with memberStatus: GroupMemberStatus) {
            self.memberLabel.text = memberStatus.userId
            if memberStatus.status == "complete"{
                self.memberVIew.checkIfInProgress = false
            } else {
                self.memberVIew.checkIfInProgress = true
            }
            self.updateUI()
    }
}
