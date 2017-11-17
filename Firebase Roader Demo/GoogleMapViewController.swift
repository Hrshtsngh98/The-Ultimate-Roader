//
//  GoogleMapViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/20/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import Firebase
import SwiftMessageBar

class GoogleMapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, MarkSpotProtocol, showSpotProtocol {
    
    @IBOutlet weak var distance_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var map_view: GMSMapView!
    
    var locationManager = CLLocationManager()
    var iskeepFocus: Bool = true
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animated_marker = GMSMarker()
    var uuid: String?
    var path: Path?
    var databaseRef: DatabaseReference?
    var storageRef = StorageReference()
    var distance: Double = 0.0
    weak var timer = Timer()
    var time = 0,length = 0.0
    var color: UIColor?
    var i = 0
    var mapBackgroundOverlayer1 = GMSGroundOverlay()
    var mapBackgroundOverlayer2 = GMSGroundOverlay()
    var mapBackgroundOverlayer3 = GMSGroundOverlay()
    let overlayTransitioningDelegate = OverlayTransitionDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "You are driving."
        setUpLocationServices()
        SwiftMessageBar.setSharedConfig(barConfig)
        databaseRef = Database.database().reference()
        start_trip()
        animationImage()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update_label), userInfo: nil, repeats: true)
    }
    
    func setUpLocationServices(){
        map_view.mapType = .satellite
        locationManager.delegate = self
        map_view.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        animated_marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animated_marker.map = map_view
        locationManager.startUpdatingLocation()
    }
    
    func start_trip() {
        gmsPath.removeAllCoordinates()
        databaseRef = Database.database().reference().child("Paths").childByAutoId()
        path = Path()
        path?.pathID = databaseRef?.key
        ManagePath.addInitialPath(pathID: (path?.pathID)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            if (path?.track.isEmpty)! {
                createMarker(loc: loc, name: "starting_point")
            }
            animated_marker.position = loc.coordinate
            
            if iskeepFocus && path?.track.isEmpty == false
            {
                let cameraPosition = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 15, bearing: getBearingBetweenTwoPoints1((path?.track.last)!, point2: loc), viewingAngle: map_view.camera.viewingAngle)
                map_view.animate(to: cameraPosition)
            }
            
            path?.track.append(loc)
            addRouteToPath(loc: loc)
            ManagePath.addCordinateTopath(latidude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
            distance = gmsPath.length(of: .geodesic)
            length = distance/1000
            DispatchQueue.main.async {
                self.distance_label.text = String(format: "%.01f", self.length)+" km"
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture == true {
            iskeepFocus = false
        }
    }
    
    @IBAction func keep_focus_btn(_ sender: UIButton) {
        iskeepFocus = true
    }
    
    func createMarker(loc: CLLocation, name: String) {
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = "Hello"
        marker.map = map_view
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func addRouteToPath(loc: CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = path_color
        polyline.strokeWidth = 5
        polyline.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = map_view
        CATransaction.commit()
    }
    
    @IBAction func finish_trip_action(_ sender: UIButton) {
        
        if time > 59 || length > 0.1 {
            timer?.invalidate()
            locationManager.stopUpdatingLocation()
            animated_marker.icon = nil
            animated_marker.map = nil
            setMapBounds()
            createMarker(loc: (path?.track.last)!, name: "ending_point")
            ManagePath.addEndpath(pathId: (path?.pathID)!)
            SwiftMessageBar.showMessageWithTitle("Trip Complete!!", message: "Fill information.", type: .success)
            createPathTableInFire()
        } else {
            SwiftMessageBar.showMessageWithTitle("Warning", message: "Drive should be 0.1 km or 1 min", type: .info)
        }
    }
    
    func createPathTableInFire() {
        let userId = Auth.auth().currentUser?.uid ?? ""
        // insert date code and add date to to dict
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let date = dateFormatter.string(from: Date())
        // upload spot
        
        
        var pathDict = ["UserId":userId, "pathName" : "New path", "pathID": self.path?.pathID ?? "", "time": String(format: "%.1d", self.time/60), "distance": String(describing: self.length),"date": date] as [String:Any]
        
        //MARK: - NEW FUNC SPOT ADDED
        if let spList = path?.spotArray {
            for spot in spList {
                let spotRef = Database.database().reference().child("SpotList").childByAutoId()
                spot.id = spotRef.key
                Database.database().reference().child("Paths").child((path?.pathID)!).child("SpotList").updateChildValues([spot.id!: "id"])
                var spotDict = ["spotId": spot.id,"description":spot.spotDescription!]
                if let lat = spot.location?.coordinate.latitude, let lng = spot.location?.coordinate.longitude, let cat = spot.cat {
                    spotDict["lat"] = "\(lat)"
                    spotDict["long"] = "\(lng)"
                    spotDict["category"] = cat
                }
                Database.database().reference().child("SpotList").child(spot.id!).updateChildValues(spotDict)
                
                if let img = spot.spotImage {
                    let data = UIImageJPEGRepresentation(img, 0.8)
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                    let imagename = "SpotImage/\(String(describing: spot.id)).jpeg"
                    storageRef = storageRef.child(imagename)
                    storageRef.putData(data!,metadata: metaData) { (storageMetaData, error) in
                        let spotImageUrl = storageMetaData?.downloadURL()?.absoluteString
                        Database.database().reference().child("SpotList").child(spot.id!).updateChildValues(["spotImageUrl":spotImageUrl])
                        spot.spotImageUrl = spotImageUrl
                    }
                }
            }
        }
        
        self.databaseRef?.updateChildValues(pathDict, withCompletionBlock: { (error, ref) in
            Database.database().reference().child("Users").child(userId).child("Paths").updateChildValues([ref.key: "id"])
            DispatchQueue.main.async {
                let alertController = UIAlertController.init(title: "Complete Drive!", message: "Go to next.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SaveDriveViewController") as? SaveDriveViewController {
                        controller.path = self.path
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                })
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func share_cordinates_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ShareLocViewController") as? ShareLocViewController {
            if let lat = path?.track.last?.coordinate.latitude, let lng = path?.track.last?.coordinate.longitude {
                controller.cord_val = "(\(String(format: "%.04f", lat)), \(String(format: "%.04f", lng)))"
            }
            controller.transitioningDelegate = self.overlayTransitioningDelegate
            controller.modalPresentationStyle = .custom
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func changemapModeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            showDarkBackgroudOnMap()
            map_view.mapType = .none
        } else {
            clearMapViewBackground()
            map_view.mapType = .hybrid
        }
    }
    
    @IBAction func markCurrentSpot(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "MarkSpotViewController") as? MarkSpotViewController {
            controller.loc = path?.track.last
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func addSpotMarker(spot: Path.Spot) {
        let marker = GMSMarker(position: (spot.location?.coordinate)!)
        marker.map = map_view
        marker.title = "\(i)"
        i += 1
        marker.snippet = spot.spotDescription
        marker.iconView = UIImageView(image: UIImage(named: "edit_camera"))
        path?.spotArray.append(spot)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ShowSpotViewController") as? ShowSpotViewController {
            controller.spot = path?.spotArray[Int(marker.title!)!]
            controller.spotIndex = Int(marker.title!)
            controller.userId = path?.userId
            controller.delegate = self
            controller.transitioningDelegate = self.overlayTransitioningDelegate
            controller.modalPresentationStyle = .formSheet
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        map_view.moveCamera(update)
        map_view.setMinZoom(self.map_view.minZoom, maxZoom: self.map_view.maxZoom)
    }
    
    func animationImage() {
        var imageArr : Array<UIImage> = []
        for i in 1...44
        {
            imageArr.append(UIImage(named : "Anim 2_\(i)")!)
        }
        animated_marker.icon = UIImage.animatedImage(with: imageArr, duration: 3.0)
    }
    
    @objc func update_label() {
        time += 1
        var hour = 0, minute = 0
        minute = time/60
        hour = time/3600
        DispatchQueue.main.async {
            self.time_label.text = String(format: "%02d", hour)+":"+String(format: "%02d", minute)
        }
    }
    
    func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
    
    func getBearingBetweenTwoPoints1(_ point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude)
        let lon2 = degreesToRadians(point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radiansBearing)
    }
    
    func showDarkBackgroudOnMap() {
        let image = UIImage(named: "map_black_background")
        var overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(84.922810, -179.194066), coordinate: CLLocationCoordinate2DMake(-84.357106, 15.164965))
        mapBackgroundOverlayer1 = GMSGroundOverlay(bounds: overlayBounds, icon: image)
        mapBackgroundOverlayer1.bearing = 0
        mapBackgroundOverlayer1.map = self.map_view
        
        overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(84.969265, -179.300975), coordinate: CLLocationCoordinate2DMake(-84.860203, -15.088306))
        mapBackgroundOverlayer2 = GMSGroundOverlay(bounds: overlayBounds, icon: image)
        mapBackgroundOverlayer2.bearing = 0
        mapBackgroundOverlayer2.map = self.map_view
        
        overlayBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(84.984656, -15.040008), coordinate: CLLocationCoordinate2DMake(-84.357106, 15.164965))
        mapBackgroundOverlayer3 = GMSGroundOverlay(bounds: overlayBounds, icon: image)
        mapBackgroundOverlayer3.bearing = 0
        mapBackgroundOverlayer3.map = self.map_view
    }
    
    func removeSpotMarker(index: Int) {
        let spot = path?.spotArray[index]
        path?.spotArray.remove(at: index)
        let ref = Database.database().reference()
        ref.child("Paths").child((path?.pathID)!).child("SpotList").child((spot?.id)!).removeValue()
        ref.child("SpotList").child((spot?.id)!).removeValue()
    }
    
    func clearMapViewBackground() {
        self.mapBackgroundOverlayer1.map = nil
        self.mapBackgroundOverlayer2.map = nil
        self.mapBackgroundOverlayer3.map = nil
        map_view.mapType = .hybrid
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
