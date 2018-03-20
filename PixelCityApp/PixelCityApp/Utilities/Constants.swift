//
//  Constants.swift
//  PixelCityApp
//
//  Created by Sonali Patel on 3/8/18.
//  Copyright © 2018 Sonali Patel. All rights reserved.
//

import Foundation

let API_KEY = "c5083ff3452b337ef3594f2909c05d18"

func flickrURL(forAPIKey key: String, withAnnotation annotation: DropablePin, andNumberOfPhotos number: Int) -> String {
     return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
   
}


