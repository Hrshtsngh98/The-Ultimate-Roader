//
//  InformationViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/25/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import  CoreLocation
import SVProgressHUD
class InformationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var temp_label: UILabel!
    @IBOutlet weak var weather_imgV: UIImageView!
    @IBOutlet weak var place_label: UILabel!
    @IBOutlet weak var compass_imgV: UIImageView!
    @IBOutlet weak var compass_circle: UIImageView!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "INFORMATION"
        temp_label.text = "\u{2103}"
        setUpLocationServices()
    }
    
    func setUpLocationServices(){
        SVProgressHUD.show()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            locationManager.stopUpdatingLocation()
            getWeather(lat: String(describing: loc.coordinate.latitude), long: String(describing: loc.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy < 0 {
            return
        }
        let magnethead = CGFloat(FTMathCalculations.DegreesToRadians(newHeading.magneticHeading))
        compass_imgV.transform = CGAffineTransform(rotationAngle: -magnethead)
        compass_circle.transform = CGAffineTransform(rotationAngle: -magnethead)
        
    }
    
    func getWeather(lat: String, long: String)
    {
        Weather.sharedInstance.get_weather(latitude: lat, longitude: long) { (temp_desc) in
            if let t_d = temp_desc as? (String,String,String) {
                if let name = Weather.Condition(rawValue: t_d.1)?.title{
                    if let img = UIImage(named: name){
                        DispatchQueue.main.async {
                            self.weather_imgV.image = img
                            self.temp_label.text = "\(t_d.0)\u{2103}"
                            self.place_label.text = t_d.2
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
