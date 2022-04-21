//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/20/22.
//

import UIKit
import MapKit

class MapController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapview: MKMapView!
    
    // MARK: - Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Action Handlers
    
    @objc func addPinsToMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let gestureLocation: CGPoint = sender.location(in: mapview)
        let coordinate: CLLocationCoordinate2D = mapview.convert(gestureLocation, toCoordinateFrom: mapview)
        
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapview.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapview.setRegion(region, animated: true)
    }
    
    // MARK: - Helper Methods
    
    func setupLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinsToMap))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        mapview.addGestureRecognizer(gesture)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapController: UIGestureRecognizerDelegate {
    
}
