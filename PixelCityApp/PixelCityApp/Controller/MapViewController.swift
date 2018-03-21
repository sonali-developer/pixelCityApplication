//
//  MapViewController.swift
//  PixelCityApp
//
//  Created by Sonali Patel on 2/21/18.
//  Copyright © 2018 Sonali Patel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
  //Outlets
    @IBOutlet weak var mapView: MKMapView!    
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
  
    //Variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    var screenSize = UIScreen.main.bounds
    var imageURLArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCollectionViewCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        registerForPreviewing(with: self, sourceView: collectionView!)
        pullUpView.addSubview(collectionView!)
        
        
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        //progressLbl?.text = "12/40 PHOTOS LOADED"
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgresLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            print(authorizationStatus.rawValue)
            print(authorizationStatus.hashValue)
            centerMapOnUserLocation()
        }
    }

}

extension MapViewController : MKMapViewDelegate {
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        removeSpinner()
        removeProgresLbl()
        cancelAllSessions()
        
        imageURLArray = []
        imageArray = []
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
       // print("Pin was dropped")
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView )
        
        let annotation = DropablePin(coordinate: touchCoordinate, identifier: "dropable pin")
        mapView.addAnnotation(annotation)
        
       //  print(flickrURL(forAPIKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40))
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveURLs(forAnnotation: annotation) { (finished) in
            print(self.imageURLArray)
            if finished {
                self.retrieveImages(handler: { (finished) in
                   self.removeSpinner()
                    self.removeProgresLbl()
                    self.collectionView?.reloadData()
                })
            }
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "dropablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func retrieveURLs(forAnnotation annotation: DropablePin, handler: @escaping (_ status: Bool) -> ()) {
        
        Alamofire.request(flickrURL(forAPIKey: API_KEY
            , withAnnotation: annotation, andNumberOfPhotos: 30)).responseJSON { (response) in
                print(response)
               // handler(true)
                guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosDictArray {
                    let postURL = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.imageURLArray.append(postURL)
                }
                handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        
        for url in imageURLArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/30 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageURLArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
            // similar to doing for task in sessionDataTask { task.cancel() }
        }
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            print("Requested\(authorizationStatus.rawValue)")
        } else {
            print("Available\(authorizationStatus.rawValue)")
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
        print(authorizationStatus.rawValue)
    }
    
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // number of items in array
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popViewController = storyboard?.instantiateViewController(withIdentifier: "PopViewController") as? PopViewController else { return }
       popViewController.initData(forImage: imageArray[indexPath.row])
        present(popViewController, animated: true, completion: nil)
    }
    
}

extension MapViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopViewController") as? PopViewController else { return nil }
        popVC.initData(forImage: imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
        
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}
