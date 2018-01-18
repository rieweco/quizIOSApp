import UIKit

class BounceButton: UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //CGAffineTransform means maintains the shape and do parallel shrink or enlarge the button
        self.transform = CGAffineTransform(scaleX: 1.1 , y: 1.1)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity // identity means change back to default
        }, completion: nil)
        
        //Here we need maintain the default touchesBegan functionality
        super.touchesBegan(touches, with: event)
        
    }
}

