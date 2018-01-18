import UIKit

class CourseTVCell: UITableViewCell {

    @IBOutlet weak var courseIdLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseSemLabel: UILabel!
    @IBOutlet weak var courseInstructorLabel: UILabel!
    @IBOutlet weak var courseBgView: UIView!
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(){
        contentView.backgroundColor = UIColor(red:240, green:240, blue:240, alpha: 1.0)
        courseBgView.layer.masksToBounds = false
        courseBgView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        courseBgView.layer.shadowOffset = CGSize(width: 10, height: 10)
        courseBgView.layer.shadowOpacity = 0.8
        
    }
    func decorate(with course: CourseInfo) {
        courseIdLabel.text = course.courseId
        courseNameLabel.text = course.name
        courseInstructorLabel.text = course.instructor
        courseSemLabel.text = course.quizInfo.description
        self.updateUI()
    }
}
