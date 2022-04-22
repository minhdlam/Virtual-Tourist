//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/20/22.
//

import UIKit
import MapKit
import CoreData

class MapController: UIViewController {
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapview: MKMapView!
    
    // MARK: - Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        zoomToLastLocation()
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
        saveToUserDefaults(latitude: coordinate.latitude, longitude: coordinate.longitude)
        saveToCoreData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        mapview.addAnnotation(annotation)
        
        zoomInMap(coordinate: coordinate)
    }
    
    // MARK: - Helper Methods
    
    func setupLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinsToMap))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        mapview.addGestureRecognizer(gesture)
    }
    
    func saveToUserDefaults(latitude: Double, longitude: Double) {
        defaults.set(latitude, forKey: "latitude")
        defaults.set(longitude, forKey: "longitude")
    }
    
    func saveToCoreData(latitude: Double, longitude: Double) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) else { return }
        let pin = NSManagedObject(entity: entity, insertInto: context)
        pin.setValue(latitude, forKey: "latitude")
        pin.setValue(longitude, forKey: "longitude")
        
        do {
            try context.save()
        } catch let error {
            showError(title: "Could not save location.", message: error.localizedDescription)
        }
    }
    
    func zoomInMap(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapview.setRegion(region, animated: true)
    }
    
    func zoomToLastLocation() {
        guard let latitude = defaults.object(forKey: "latitude") as? Double else { return }
        guard let longitude = defaults.object(forKey: "longitude") as? Double else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        zoomInMap(coordinate: coordinate)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapController: UIGestureRecognizerDelegate {
    
}
