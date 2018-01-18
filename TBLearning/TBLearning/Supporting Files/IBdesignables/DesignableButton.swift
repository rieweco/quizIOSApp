
import UIKit

//IB stands for interface builder
@IBDesignable class DesignableButton: BounceButton {
    
    //@IBInspectable relates to the attributes inspecter
    // setUp, click the button. choose the class you want be DesignableButton class.
    // then, you'll find out in the attributes inspecter, you can update borderWidth
    @IBInspectable var borderWidth: CGFloat = 0.0 {//borderWidth initialize to 0.0
        didSet{
            //self, refers to the UIButton
            self.layer.borderWidth = borderWidth
        }
    }
    
    //UIcolor gives you a color picker in attributes inspecter
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
}

