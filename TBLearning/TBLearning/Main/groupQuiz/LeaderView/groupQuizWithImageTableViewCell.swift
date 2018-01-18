//
//  groupQuizWithImageTableViewCell.swift
//  TBLearning
//
//  Created by Liwei Jiao on 12/7/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.


import UIKit

protocol groupQuizWithImageTableViewCellDelegate : class {
    func groupQuizTVCellCheckAnswerBtnTapped(_ sender: groupQuizWithImageTableViewCell)
}

class groupQuizWithImageTableViewCell: UITableViewCell {

    @IBOutlet weak var answerOptionImage: UIImageView!
    @IBOutlet weak var answerOptionTextView: UITextView!
    @IBOutlet weak var answerOptionBtn: UIButton!
    weak var delegate: groupQuizWithImageTableViewCellDelegate?
    private(set) var questionId: String?{
        didSet{
            
        }
    }
    
    private(set) var questionAnswerOption: ServiceAnswers?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerOptionTextView.isEditable = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @IBAction func answerOptoinBtnTapped(_ sender: UIButton) {
        delegate?.groupQuizTVCellCheckAnswerBtnTapped(self)
        
    }
    
    func decorate(with answerOption: ServiceAnswers, for questionId: String){
        self.questionId = questionId
        self.questionAnswerOption = answerOption
        self.answerOptionTextView.text = "\n" + answerOption.text
        answerOptionImage.downloadedFrom(link: answerOption.imageUri!)
    }
    
}

