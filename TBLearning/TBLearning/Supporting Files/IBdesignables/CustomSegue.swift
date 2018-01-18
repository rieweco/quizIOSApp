import UIKit

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        scaleTransform()
    }
    
    func scaleTransform(){
        let destinationVC = self.destination
        let sourceVC = self.source
        
        let containerView = sourceVC.view.superview
        let sourceViewCenter = sourceVC.view.center
        
        destinationVC.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        destinationVC.view.center = sourceViewCenter
        
        containerView?.addSubview(destinationVC.view)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            destinationVC.view.transform = CGAffineTransform.identity
        }) { (success) in
            sourceVC.present(destinationVC, animated: false, completion: nil)
        }
        
    }
}
