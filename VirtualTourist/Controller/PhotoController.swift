//
//  PhotoController.swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/20/22.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class PhotoController: UIViewController {
    
    // MARK: - Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchResultController: NSFetchedResultsController<Photo>?
    var coordinate: CLLocationCoordinate2D?
    var images = [UIImage]()
    
    var pin: Pin {
        guard let coordinate = coordinate else { return Pin() }
        let pin = Pin(context: context)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        return pin
    }
    
    var samplePhotos = [Photo]()
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var fetchingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showPinAnnotation()
        activityIndicator.startAnimating()
        
        setupFetchResultsController()
        fetchPhotos()
        fetchPhotosFromCoreData()
        
//        if checkIfPhotosExist(forPin: pin) {
//            fetchPhotosFromCoreData()
//        } else {
//            fetchPhotos()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchResultController = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func handleNewCollectionPressed(_ sender: UIButton) {
    }
    
    // MARK: - Helper Methods
    
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchResultController?.performFetch()
        } catch {
            fatalError()
        }
        
        collectionView.reloadData()
    }
    
    func saveToCoreData(imageData: Data) {
        DispatchQueue.main.async {
            guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.context) else { return }
            let photo = NSManagedObject(entity: entity, insertInto: self.context)
            photo.setValue(imageData, forKey: "image")
            photo.setValue(self.pin, forKey: "pin")
            photo.setValue(Date(), forKey: "creationDate")
            
            do {
                try self.context.save()
            } catch let error {
                self.showError(title: "Unable to save photo to core data.", message: error.localizedDescription)
            }
        }
    }
    
    func deleteFromCoreData() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        do {
            let photos = try context.fetch(fetchRequest)
            for photo in photos {
                context.delete(photo)
                print("DEBUG: photo deleted successfully")
            }
        } catch let error {
            showError(title: "Unable to fetch photos from Core Data.", message: error.localizedDescription)
        }
    }
    
    func checkIfPhotosExist(forPin pin: Pin) -> Bool {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        guard let photos = try? context.fetch(fetchRequest) else { return false }
        for photo in photos {
   
        }

        let doesExist = !photos.isEmpty ? true : false
        return doesExist
    }
    
    func fetchPhotosFromCoreData() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()

//        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        do {
            let photos = try context.fetch(fetchRequest)
            for photo in photos {
                print("Photo pin from core data is \(photo.pin)")
                samplePhotos.append(photo)
                collectionView.reloadData()
            }
        } catch let error {
            showError(title: "Unable to fetch photos from Core Data.", message: error.localizedDescription)
        }
    }
    
    func fetchPhotos() {
        guard let coordinate = coordinate else {
            return
        }
        
        if fetchResultController?.fetchedObjects?.count == 0 {
            FlickrManager.shared.fetchPhotos(forCoordinate: coordinate) { result in
                self.shouldHideViews(true)
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let photographs):
                    for photograph in photographs {
                        FlickrManager.shared.downloadImage(forPhotograph: photograph) { result in
                            switch result {
                            case .success(let data):
                                self.saveToCoreData(imageData: data)
                                //                            self.collectionView.reloadData()
                            case .failure(let error):
                                self.showError(title: "Unable to download image.", message: error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error): self.showError(title: "Unable to fetch photos from Flickr.", message: error.localizedDescription)
                }
            }
        }

    }
    
    func showPinAnnotation() {
        guard let coordinate = coordinate else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        zoomInMap(mapView: mapView, coordinate: coordinate)
    }
    
    func shouldHideViews(_ success: Bool) {
        activityIndicator.isHidden = success
        fetchingLabel.isHidden = success
    }
    
    func setupFlowLayout() {
        let spacing: CGFloat = 3.0
        let dimension = ((view.frame.size.width) - (2 * spacing)) / spacing
        
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}

// MARK: - UICollectionView Delegate/DataSource

extension PhotoController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultController?.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
//        let photo = fetchResultController?.object(at: indexPath)
//        print("From indexpath, photo is \(photo)")
//        if let imageData = photo?.image, let image = UIImage(data: imageData) {
//            cell.imageView.image = image
//        }
        let data = samplePhotos[indexPath.item].image
        let image = UIImage(data: data!)
        cell.imageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
