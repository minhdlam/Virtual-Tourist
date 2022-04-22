//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Duc Lam on 4/22/22.
//

import Foundation

struct FlickrReponse: Codable {
    let photos: Photographs
    let stat: String
}

struct Photographs: Codable {
    let page, pages, perpage, total: Int
    let photo: [Photograph]
}

struct Photograph: Codable {
    let id, owner, secret, server: String
}




