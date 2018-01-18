//
//  customLabelView.swift
//  groupQuizNetWorkCall
//
//  Created by Liwei Jiao on 11/9/17.
//  Copyright © 2017 frontOfClassTeam. All rights reserved.
//

import UIKit

class customLabelView: UIView {
    private var innerProgress: Bool = true
    var checkIfInProgress: Bool {
            set (newProgress) {
                if newProgress {
                    innerProgress = true
                } else{
                    innerProgress = false
                }
                setNeedsDisplay()
            }
            get {
                return innerProgress
            }
    }

    override func draw(_ rect: CGRect) {
        Log.info(bounds)
            GroupQuizProgressLabel.drawMemberQuizStatusLabel(frame: bounds,
                                                             checkIfQuizComplete: checkIfInProgress)
    }
}
