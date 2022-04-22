//
//  PhotoController.swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/20/22.
//

import UIKit
import CoreLocation
import MapKit

private let reuseIdentifier = "PhotoCell"

class PhotoController: UIViewController {
    
    // MARK: - Properties
    
    var coordinate: CLLocationCoordinate2D?
    var images = [UIImage]()
    
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
        fetchPhotos()
    }
    
    // MARK: - IBActions
    
    @IBAction func handleNewCollectionPressed(_ sender: UIButton) {
    }
    
    // MARK: - Helper Methods
    
    func fetchPhotos() {
        guard let coordinate = coordinate else {
            return
        }
        
        FlickrManager.shared.fetchPhotos(forCoordinate: coordinate) { result in
            self.shouldHideViews(true)
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let photographs):
                for photograph in photographs {
                    FlickrManager.shared.downloadImage(forPhotograph: photograph) { result in
                        switch result {
                        case .success(let image):
                            self.images.append(image)
                            self.collectionView.reloadData()
                        case .failure(let error):
                            self.showError(title: "Unable to download image.", message: error.localizedDescription)
                        }
                    }
                }
            case .failure(let error): self.showError(title: "Unable to fetch photos from Flickr.", message: error.localizedDescription)
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
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
