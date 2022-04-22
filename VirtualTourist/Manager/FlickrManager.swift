//
//  FlickrManager.swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/20/22.
//

import Foundation
import MapKit

class FlickrManager {
    // let url = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=API_KEY_&lat=\35.019238098&lon=45.987918237&per_page=20&page=1&format=json&nojsoncallback=1"
    static let shared = FlickrManager()
    
    static let apiKey = "5450ddcc2aa771511de3b222e1483d64"
    static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=" + apiKey
    
    private init(){}
    
    func fetchPhotos(forCoordinate coordinate: CLLocationCoordinate2D, completion: @escaping (Result<[Photograph], Error>) -> Void) {
        let urlString = FlickrManager.baseURL + "&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&per_page=50&page=1&format=json&nojsoncallback=1"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
            
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let result = try decoder.decode(FlickrReponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result.photos.photo))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func downloadImage(forPhotograph photograph: Photograph, completion: @escaping(Result<UIImage, Error>) -> Void) {
        let serverId = photograph.server
        let id = photograph.id
        let secret = photograph.secret
        let urlString = "https://live.staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                completion(.success(image))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}
