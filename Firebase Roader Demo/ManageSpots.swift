//
//  ManageSpots.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 11/14/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ManageSpots: NSObject {
    static func getAllSpots(spotDict: [String:String],completion: @escaping handler) {
        let ref = Database.database().reference()
        var spotArray :[Path.Spot] = []
        for key in spotDict.keys {
            ref.child("SpotList").child(key).observe(.value, with: { (snapshot) in
                var spot = Path.Spot(withSnap: snapshot)
                spotArray.append(spot)
                if spotDict.count == spotArray.count {
                    completion(spotArray)
                }
            })
        }
    }
}
