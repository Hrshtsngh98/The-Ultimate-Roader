//
//  FollowPathViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/30/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SVProgressHUD
import SwiftMessageBar
import FirebaseDatabase

enum buttonName: String {
    case StartTrip = "start"
    case StopTrip = "stop"
}

class FollowPathViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, showSpotProtocol {

    var FollowPathDistanceDelta: CLLocationDistance = 5 //meters
    @IBOutlet weak var map_view: GMSMapView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var start_following_btn: UIButton!
    
    var polyline = GMSPolyline()
    var polylineFollow = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var gmsFollowPath = GMSMutablePath()
    var animated_marker = GMSMarker()
    var myTrack: [CLLocation] = []
    var pathToFollow: Path?
    var location: CLLocation?
    var start_following: Bool = false
    var follow_btn_case: buttonName = .StartTrip
    let overlayTransitioningDelegate = OverlayTransitionDelegate()
    
    var currentLocation : CLLocation? {
        didSet {
            self.currentLocationDidSet()
        }
    }
    
    var isFinished : Bool {
        if let finishLocation = pathToFollow?.track.last, let loc = currentLocation {
            let distance = loc.distance(from: finishLocation)
            return distance < FollowPathDistanceDelta
        }
        return false
    }
    
    var isAway : Bool {
        if let finishLocation = pathToFollow?.track.first, let loc = currentLocation {
            let distance = loc.distance(from: finishLocation)
            return distance > FollowPathDistanceDelta
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Following Path"
        map_view.mapType = .satellite
        locationManager.delegate = self
        map_view.delegate = self
        locationManager.startUpdatingLocation()
        start_following_btn.isEnabled = false
        DispatchQueue.main.async {
            self.setMapBounds()
            SVProgressHUD.dismiss()
        }
        animated_marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animated_marker.map = map_view
        animationImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        createMarker(loc: (pathToFollow?.track.first)!, name: "starting_point")
        createMarker(loc: (pathToFollow?.track.last)!, name: "ending_point")
        map_view.camera = GMSCameraPosition(target: (pathToFollow?.track.first?.coordinate)!, zoom: 10, bearing: 0, viewingAngle: 0)
        
        for cord in (pathToFollow?.track)! {
            addRouteToPath(loc: cord)
        }
        
        var i = 0
        for spot in (pathToFollow?.spotArray)! {
            let marker = GMSMarker(position: (spot.location!.coordinate))
            marker.map = map_view
            marker.iconView = UIImageView(image: UIImage(named: "edit_camera"))
            marker.title = "\(i)"
            i += 1
            marker.snippet = spot.spotDescription
            //marker.icon = UIImage(named: name)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last as CLLocation!
            else{
                return
        }

        currentLocation = location
        animated_marker.position = location.coordinate
        if start_following {
            myTrack.append(location)
            createMarker(loc: myTrack.first!, name: "starting_point")
            addRouteToPath2(loc: location)
        }
        
        if !isAway {
            SwiftMessageBar.showMessageWithTitle("Start reached.", message: "Press start trip.", type: .info)
            start_following_btn.isEnabled = true
        }
        
        if isFinished {
            start_following = false
            createMarker(loc: myTrack.last!, name: "ending_point")
            popUpForPathComplete()
        }
    }
    
    func currentLocationDidSet() {
        guard currentLocation!.timestamp.timeIntervalSinceNow < 10.0 else {
            return
        }
        animated_marker.position = (self.currentLocation?.coordinate)!
        
        if isAway == false {
            print("Start")
        }
    }

    @IBAction func follow_path_action(_ sender: UIButton) {
        if follow_btn_case == .StartTrip {
            DispatchQueue.main.async {
                self.start_following_btn.setTitle("STOP FOLLOWING", for: .normal)
            }
            follow_btn_case = .StopTrip
            start_following = true
            
        } else if follow_btn_case == .StopTrip {
            start_following = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ShowSpotViewController") as? ShowSpotViewController {
            controller.spot = pathToFollow?.spotArray[Int(marker.title!)!]
            controller.spotIndex = Int(marker.title!)
            controller.delegate = self
            controller.userId = pathToFollow?.userId
            controller.transitioningDelegate = self.overlayTransitioningDelegate
            controller.modalPresentationStyle = .formSheet
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func removeSpotMarker(index: Int) {
        let spot = pathToFollow?.spotArray[index]
        pathToFollow?.spotArray.remove(at: index)
        let ref = Database.database().reference()
        ref.child("Paths").child((pathToFollow?.pathID)!).child("SpotList").child((spot?.id)!).removeValue()
        ref.child("SpotList").child((spot?.id)!).removeValue()
    }
    
    func createMarker(loc: CLLocation, name: String) {
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = name
        marker.map = map_view
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func addRouteToPath(loc: CLLocation) {
        gmsFollowPath.add(loc.coordinate)
        polylineFollow.path = gmsFollowPath
        polylineFollow.strokeColor = path_color
        polylineFollow.strokeWidth = 5
        polylineFollow.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polylineFollow.map = map_view
        CATransaction.commit()
    }
    
    func addRouteToPath2(loc: CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = UIColor.red
        polyline.strokeWidth = 5
        polyline.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = map_view
        CATransaction.commit()
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsFollowPath)
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
    
    func popUpForPathComplete() {
        ManagePath.addFollowedUser(path: pathToFollow!)
        let alert = UIAlertController(title: "Trip complete!!", message: "You have reach destination.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (act) in
            for controller in (self.navigationController?.viewControllers)! {
                if controller.isKind(of: DriveOptionsViewController.self)  {
                    self.locationManager.stopUpdatingLocation()
                    DispatchQueue.main.async {
                        self.navigationController?.popToViewController(controller, animated: true)
                    }
                }
            }
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func putSpots() {
        for spot in pathToFollow!.spotArray {
            let marker = GMSMarker(position: spot.location!.coordinate)
            marker.map = map_view
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
