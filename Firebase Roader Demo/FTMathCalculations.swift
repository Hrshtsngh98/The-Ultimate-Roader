//
//  FTMathCalculations.swift
//  Ardhi
//
//  Created by Fatima Hussain on 10/8/15.
//  Copyright © 2015 Solutions 4 Mobility. All rights reserved.
//

import UIKit
import CoreLocation

class FTMathCalculations: NSObject {

    class func DegreesToRadians (_ value:Double) -> Double {
        return (value * Double.pi / 180.0)
    }
    
    class func RadiansToDegrees (_ value:Double) -> Double {
        return (value * 180.0 / Double.pi)
    }
    
    class func directionForCoordinate(_ coordinates:CLLocationCoordinate2D) -> String {
        let latitude = coordinates.latitude
        let longitude = coordinates.longitude
        
        var latitudeSeconds = Int(round(abs(latitude * 3600)))
        let latitudeDegrees = latitudeSeconds / 3600
        latitudeSeconds = latitudeSeconds % 3600
        let latitudeMinutes = latitudeSeconds / 60
        latitudeSeconds %= 60
        
        var longitudeSeconds = Int(round(abs(longitude * 3600)))
        let longitudeDegrees = longitudeSeconds / 3600
        longitudeSeconds = longitudeSeconds % 3600
        let longitudeMinutes = Int(longitudeSeconds / 60)
        longitudeSeconds %= 60
        
        let latitudeDirection = (latitude >= 0) ? "N" : "S"
        let longitudeDirection = (longitude >= 0) ? "E" : "W"
        
        return "\(latitudeDegrees)° \(latitudeMinutes)' \(latitudeSeconds)\" \(latitudeDirection), \(longitudeDegrees)° \(longitudeMinutes)' \(longitudeSeconds)\" \(longitudeDirection)"
    }
    
    class func distanceBetweenTwoLocations(_ firstLocation: CLLocation, secondLocation: CLLocation) -> Double{ // distance in KM
        return firstLocation.distance(from: secondLocation)/1000
    }
    
   class func timeInHoursAndMins(_ timeWaiting: TimeInterval) -> (hours: Int, mins: Int) {
        let totalTime = round(timeWaiting)
        let hours = Int(totalTime / 3600)
        let mins = Int((totalTime.truncatingRemainder(dividingBy: 3600)) / 60)
        return (hours, mins)
    }
}
