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
    
    var pins = [Pin]()
    var annotations = [MKAnnotation]()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        zoomToLastLocation()
        fetchPinsFromCoreData()
    }
    
    // MARK: - Action Handlers
    
    @objc func addPinsToMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        let gestureLocation: CGPoint = sender.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(gestureLocation, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        mapView.addAnnotation(annotation)
        
        saveToUserDefaults(latitude: coordinate.latitude, longitude: coordinate.longitude)
        saveToCoreData(latitude: coordinate.latitude, longitude: coordinate.longitude)
        zoomInMap(mapView: mapView, coordinate: coordinate)
    }
    
    // MARK: - Helper Methods
    
    func setupLongPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinsToMap))
        gesture.minimumPressDuration = 0.5
        gesture.delegate = self
        mapView.addGestureRecognizer(gesture)
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
            showError(title: "Unable to save location.", message: error.localizedDescription)
        }
    }
    
    func fetchPinsFromCoreData() {
        do {
            pins = try context.fetch(Pin.fetchRequest())
            for pin in pins {
                let latitude = CLLocationDegrees(pin.latitude)
                let longitude = CLLocationDegrees(pin.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
        } catch let error {
            showError(title: "Unable to fetch pin locations.", message: error.localizedDescription)
        }
    }
    
    func zoomToLastLocation() {
        guard let latitude = defaults.object(forKey: "latitude") as? Double else { return }
        guard let longitude = defaults.object(forKey: "longitude") as? Double else { return }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        zoomInMap(mapView: mapView, coordinate: coordinate)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MapController: UIGestureRecognizerDelegate {
    
}

// MARK: - MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            let photoController = storyboard?.instantiateViewController(withIdentifier: "PhotoController") as! PhotoController
            photoController.coordinate = annotation.coordinate
            navigationController?.pushViewController(photoController, animated: true)
        }
    }
}
