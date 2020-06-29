import Foundation
import UIKit

class Utils:NSObject {
    
    static func displayAlert(_ message:String, vc:UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
}
