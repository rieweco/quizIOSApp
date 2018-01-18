import UIKit

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

class AlertController {
     static func showAlert(_ inViewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //custom AlertController title and message font
        let titleFont = [ NSAttributedStringKey.font: UIFont(name: "AmericanTypewriter-Bold", size: 20)! ]
        let messageFont = [ NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-Medium", size: 16)!]
        let attributedTitle = NSMutableAttributedString(string: "\(title)", attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "\(message)", attributes: messageFont)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        inViewController.present(alert, animated: true, completion: nil)
    }

}

