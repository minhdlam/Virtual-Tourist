//
//  UIViewController Ext..swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/21/22.
//

import UIKit
import MapKit

extension UIViewController {
    func showError(title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func zoomInMap(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}
