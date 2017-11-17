//
//  SaveDriveViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/24/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftMessageBar

class SaveDriveViewController: UIViewController {

    @IBOutlet weak var map_view: GMSMapView!
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animated_marker = GMSMarker()
    var path: Path?
    var databaseRef: DatabaseReference?
    @IBOutlet weak var save_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FINISH PATH"
        map_view.mapType = .satellite
        databaseRef = Database.database().reference()
        SwiftMessageBar.setSharedConfig(barConfig)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if let track = path?.track{
            for loc in track{
                addRouteToPath(loc: loc)
            }
            createMarker(loc: track.first!, name: "starting_point")
            createMarker(loc: track.last!, name: "ending_point")
        }
        setMapBounds()
    }
    
    func createMarker(loc: CLLocation, name: String) {
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = "Hello"
        marker.map = map_view
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        map_view.moveCamera(update)
        map_view.setMinZoom(self.map_view.minZoom, maxZoom: self.map_view.maxZoom)
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
    
    @IBAction func save_btn_action(_ sender: UIButton) {
        if path?.pathName?.characters.count != 0 {
            databaseRef?.child("Paths").child((path?.pathID)!).updateChildValues(["pathName": path?.pathName ?? "New Path", "pathType": path?.pathType.rawValue ?? "public", "difficulty": path?.difficulty.rawValue ?? "easy"])
        
            SwiftMessageBar.showMessageWithTitle("Success", message: "Path saved successfully.", type: .success)
            for controller in (navigationController?.viewControllers)! {
                if controller.isKind(of: DriveOptionsViewController.self)  {
                    navigationController?.popToViewController(controller, animated: true)
                }
            }
        } else {
            SwiftMessageBar.showMessageWithTitle("Path name empty.", message: "Enter path name.", type: .error)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ModifyPathDetailsViewController {
            controller.path = path
        }
    }

}
