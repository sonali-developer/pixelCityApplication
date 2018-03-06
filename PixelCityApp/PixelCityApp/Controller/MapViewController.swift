//
//  MapViewController.swift
//  PixelCityApp
//
//  Created by Sonali Patel on 2/21/18.
//  Copyright © 2018 Sonali Patel. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController {

   
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
       mapView.delegate = self
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    }

}

extension MapViewController : MKMapViewDelegate {
    
}

