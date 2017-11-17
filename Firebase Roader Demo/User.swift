//
//  User.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/18/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class User {
    
    var firstname: String?
    var lastname: String?
    var city: String?
    var email: String?
    var password: String?
    var userImageUrl: String?
    var userID: String?
    var pathList: [String:Any] = [:]
    init(withsnap snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? Dictionary<String,Any> else { return }
        userID = dict["UserId"] as? String
        firstname = dict["FirstName"] as? String
        lastname = dict["LastName"] as? String
        city = dict["City"] as? String
        email = dict["EmailID"] as? String
        password = dict["Password"] as? String
        userImageUrl = dict["userImageUrl"] as? String
        if let path_dict = dict["Paths"] as? [String:Any] {
            pathList = path_dict
        }
    }
    
    init(withDict dict_user: [String:Any]) {
        guard let dict = dict_user as? Dictionary<String,Any> else { return }
        userID = dict["UserId"] as? String
        firstname = dict["FirstName"] as? String
        lastname = dict["LastName"] as? String
        city = dict["City"] as? String
        email = dict["EmailID"] as? String
        password = dict["Password"] as? String
        userImageUrl = dict["userImageUrl"] as? String
        if let path_dict = dict["Paths"] as? [String:Any] {
            pathList = path_dict
        }
    }
}

typealias handler = (Any) -> ()

class ManipulateUser: NSObject {
    private override init() {}
    static var sharedinstance = ManipulateUser()
    
     func getUser(completion: @escaping handler){
        var user: User?
        let ref: DatabaseReference = Database.database().reference()
        let u = Auth.auth().currentUser
        
        ref.child("Users").child((u?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot  as? DataSnapshot {
                user = User(withsnap: data)
                completion(user)
            }
        }
    }
    
    static func getPathNameList(completion: @escaping handler) {
        var pathList: [String:Any]?
        let ref: DatabaseReference = Database.database().reference()
        let u = Auth.auth().currentUser
        
        ref.child("Users").child((u?.uid)!).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else {
                return
            }
            guard let list = value["Paths"] as? [String:Any] else {
                return
            }
            pathList = list
            completion(pathList)
        }
    }
    
    static func getUserForpath(path: Path, completion: @escaping handler) {
        guard let userlist = path.followed_user as? [String:String] else {
            return
        }
        
        let ref: DatabaseReference = Database.database().reference()
        var userObjlist: [User] = []
        var allObjList: [String: User] = [:]
        
        ref.child("Users").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? [String:Any] {
                for v in val {
                    if let dict = v.value as? Dictionary<String,Any> {
                        allObjList[v.key] = User(withDict: dict)
                    }
                }
                for user_key in userlist.keys {
                    userObjlist.append(allObjList[user_key]!)
                }
                completion(userObjlist)
            }
        }

//        for user in userlist.keys {
//            ref.child("Users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
//                userObjlist.append(User(withsnap: snapshot))
//                if userObjlist.count == userlist.keys.count {
//                    completion(userObjlist)
//                }
//            })
//        }
    }
}
