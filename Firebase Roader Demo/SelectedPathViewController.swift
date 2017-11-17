//
//  SelectedPathViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/23/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SVProgressHUD
import FirebaseDatabase
class SelectedPathViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate, showSpotProtocol {

    var locationManager = CLLocationManager()
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var path: Path?
    var name = ""
    var file_name: String?
    let overlayTransitioningDelegate = OverlayTransitionDelegate()
    
    @IBOutlet weak var map_view: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = name
        setUpLocationServices()
        setUpPath()
    }

    func setUpLocationServices(){
        map_view.mapType = .satellite
        locationManager.delegate = self
        map_view.delegate = self
    }
    
    func setUpPath() {
        SVProgressHUD.show()
        ManagePath.getPathFromFile(name: file_name!) { (track) in
            if let cord_list = track as? [CLLocation] {
                self.path?.track = cord_list
            }
            ManageSpots.getAllSpots(spotDict: self.path!.spotDict, completion: { (array) in
                if let sp_arr = array as? [Path.Spot] {
                    self.path?.spotArray = sp_arr
                    DispatchQueue.main.async {
                        self.putSpots()
                    }
                }
                SVProgressHUD.dismiss()
            })
            DispatchQueue.main.async {
                self.makePath()
                self.setMapBounds()
            }
        }
    }
    
    func makePath() {
        createMarker(loc: (path?.track.first)!, name: "starting_point")
        createMarker(loc: (path?.track.last)!, name: "ending_point")
        map_view.camera = GMSCameraPosition(target: (path?.track.first?.coordinate)!, zoom: 10, bearing: 0, viewingAngle: 0)
        
        for cord in (path?.track)! {
            addRouteToPath(loc: cord)
        }
    }
    
    @IBAction func follow_path_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "FollowPathViewController") as? FollowPathViewController {
            controller.pathToFollow = path
            navigationController?.pushViewController(controller, animated: true)
        }
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
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = map_view
        CATransaction.commit()
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        map_view.moveCamera(update)
        map_view.setMinZoom(self.map_view.minZoom, maxZoom: self.map_view.maxZoom)
    }
    
    func putSpots() {
        var i = 0
        for spot in path!.spotArray {
            let marker = GMSMarker(position: spot.location!.coordinate)
            marker.map = map_view
            marker.title = "\(i)"
            i += 1
            marker.snippet = spot.spotDescription
            marker.iconView = UIImageView(image: UIImage(named: "edit_camera"))
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ShowSpotViewController") as? ShowSpotViewController {
            controller.spot = path?.spotArray[Int(marker.title!)!]
            controller.spotIndex = Int(marker.title!)
            controller.delegate = self
            controller.userId = path?.userId
            controller.transitioningDelegate = self.overlayTransitioningDelegate
            controller.modalPresentationStyle = .currentContext
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func removeSpotMarker(index: Int) {
        let spot = path?.spotArray[index]
        path?.spotArray.remove(at: index)
        let ref = Database.database().reference()
        ref.child("Paths").child((path?.pathID)!).child("SpotList").child((spot?.id)!).removeValue()
        ref.child("SpotList").child((spot?.id)!).removeValue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
