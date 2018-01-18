import UIKit

@IBDesignable class DesignableView: UIView {
    @IBInspectable var cornerRaidus: CGFloat = 0.0{
        didSet{
            self.layer.cornerRadius = cornerRaidus
            self.layer.masksToBounds = true
        }
    }
}

