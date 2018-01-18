//
//  QuizCollectionViewCell.swift
//  TBLearning
//
//  Created by Liwei Jiao on 11/13/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import UIKit

class QuizCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var questionBgImg: UIImageView!
    @IBOutlet weak var questionLabelVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var questionNumLabel: UILabel!
    @IBOutlet weak var pointsAllocated: UILabel!
    
    var selectedQuestion:ServiceQuestion? = nil {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        questionNumLabel.text = selectedQuestion?.title
    }
    override func awakeFromNib() {
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.cornerRadius = 10
    }
}
