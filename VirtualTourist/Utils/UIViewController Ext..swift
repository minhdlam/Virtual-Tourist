//
//  UIViewController Ext..swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/21/22.
//

import UIKit

extension UIViewController {
    func showError(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
