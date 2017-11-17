//
//  Spot.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 11/11/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

//enum Icon {
//    enum Version: String {
//        case Small = "small"
//        case Medium = "medium"
//
//        var name: String { return self.rawValue }
//    }
//}

extension Path {
    class Spot: NSObject {
        
        enum Category: String {
            case General = "general"
            case Warning = "warning"
            case Recommendation = "recommendation"
            //case Icon = "icon"
            static var allValues = [General, Warning, Recommendation]
            // Returns category icon with specified version. Ex: reccomendation_small.
//            func icon(_ version: Icon.Version) -> UIImage? { return UIImage(named: "\(self.rawValue)_\(version.rawValue)") }
        }
        
        var id: String?
        var spotDescription : String? = ""
        var location : CLLocation?
        var spotImageUrl : String?
        var cat : String?
        var spotImage: UIImage?
        var category: Category = .General
        
        init(withSnap snapshot:DataSnapshot) {
            guard let dict = snapshot.value as?[String : Any] else { return  }
            id = dict["spotId"] as? String
            cat = dict["category"] as? String
            spotDescription = dict["description"] as? String
            //category = Category(rawValue: cat!)!
            let latDegree = CLLocationDegrees(exactly: Double(dict["lat"] as! String)!)
            let lngDegree = CLLocationDegrees(exactly: Double(dict["long"] as! String)!)
            location = CLLocation(latitude: latDegree!, longitude: lngDegree!)
            
            if let urlStr = dict["spotImageUrl"] as? String, let url = URL(string: urlStr), let imgData = try? Data.init(contentsOf: url) {
                spotImageUrl = urlStr
                spotImage = UIImage(data: imgData)
            }
        }
        
        override required init() {
            super.init()
        }
    }
}





