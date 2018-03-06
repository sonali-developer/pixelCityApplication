//
//  DropablePin.swift
//  PixelCityApp
//
//  Created by Sonali Patel on 3/6/18.
//  Copyright © 2018 Sonali Patel. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DropablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
