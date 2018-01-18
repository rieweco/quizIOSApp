//
//  AnswerTableViewCell.swift
//  TBLearning
//
//  Created by Liwei Jiao on 11/15/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var optionTextView: UITextView!
    @IBOutlet weak var optionBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        optionTextView.isEditable = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func decorate(with answer: ServiceAnswers, withPoints point: Int) {
        optionTextView.text = answer.text
        optionBtn.setTitle(answer.value, for: .normal)
    }

}
