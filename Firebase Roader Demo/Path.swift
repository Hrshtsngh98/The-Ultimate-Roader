//
//  Path.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/22/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Path: NSObject {
    
    var pathID: String?
    var time: String?
    var distance: String?
    var pathName: String?
    var createdDate: String?
    var followed_user: Dictionary<String,Any> = [:]
    var pathType: PathType = .Private
    var difficulty: Difficulty = .Easy
    var track: Array<CLLocation> = []
    var spotArray: [Spot] = []
    var spotDict: [String:String] = [:]
    var userId: String?
    init(withsnap snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? Dictionary<String,Any> else { return }
        pathName = dict["pathName"] as? String
        pathID = dict["pathID"] as? String
        time = dict["time"] as? String
        distance = dict["distance"] as? String
        createdDate = dict["date"] as? String
        userId = dict["UserId"] as? String
        if let follow_dict = dict["FollowedUsers"] as? [String:Any] {
            followed_user = follow_dict
        }
        
        if let path_type = dict["pathType"] as? String {
            self.pathType = PathType(rawValue: path_type) ?? .Private
        }
        if let difficulty = dict["difficulty"] as? String {
            self.difficulty = Difficulty(rawValue: difficulty) ?? .Easy
        }
        if let d = dict["SpotList"] as? [String:String] {
            spotDict = d
        }
    }
    
    init(withDict dict: Dictionary<String,Any>) {
        pathName = dict["pathName"] as? String
        pathID = dict["pathID"] as? String
        time = dict["time"] as? String
        distance = dict["distance"] as? String
        createdDate = dict["date"] as? String
        userId = dict["UserId"] as? String
        spotArray = []
        if let follow_dict = dict["FollowedUsers"] as? [String:Any] {
            followed_user = follow_dict
        }
        if let path_type = dict["pathType"] as? String {
            self.pathType = PathType(rawValue: path_type) ?? .Private
        }
        if let difficulty = dict["difficulty"] as? String {
            self.difficulty = Difficulty(rawValue: difficulty) ?? .Easy
        }
        if let d = dict["SpotList"] as? [String:String] {
            spotDict = d
        }
    }
    
    enum Difficulty: String {
        case Easy = "easy"
        case Medium = "medium"
        case Hard = "hard"
        static let allValues: [Difficulty] = [.Easy, .Medium, .Hard]
    }
    
    enum PathType: String {
        case Public = "public"
        case Private = "private"
        static let allValues: [PathType] = [.Public, .Private]
    }
    
    override required init() { }
}

typealias completionhandler = (Any) -> ()

class ManagePath: NSObject {
    
    static var doc_url: URL?
    static var file_url: URL?
    static var flag = true
    static let fileManager = FileManager.default
    static var fileHandle: FileHandle?
    
    private override init() {}
    static var sharedinstance = ManagePath()
    
    static func addInitialPath(pathID: String) {
        flag = true
        do {
            doc_url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                file_url = doc_url?.appendingPathComponent("\(pathID).json")
                let initial = ("{\"path\":[" as NSString).data(using: String.Encoding.utf8.rawValue)
                if let url = file_url {
                    if fileManager.fileExists(atPath: (url.path)) {
                        fileHandle = FileHandle(forUpdatingAtPath: (url.path))
                    } else if fileManager.createFile(atPath: (url.path), contents: initial, attributes: nil) {
                        fileHandle = FileHandle(forWritingAtPath: (url.path))
                }
            }
        }
        catch let error as NSError{
            print(error.description)
        }
        
    }
    
    static func addEndpath(pathId: String) {
        
        guard let url = file_url else{
            return
        }
        let fileHandle = FileHandle(forWritingAtPath: (url.path))
        fileHandle?.seekToEndOfFile()
        fileHandle?.write("]}".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
        
        uploadToFireBase(pathId: pathId)
    }
    
    static func addCordinateTopath(latidude: Double, longitude: Double) {
        
        fileHandle?.seekToEndOfFile()
        if flag{
            let data = "{\"latitude\":\"\(latidude)\", \"longitude\":\"\(longitude)\"}"
            fileHandle?.write(data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
            flag = false
        }
        else {
            let data = ",{\"latitude\":\"\(latidude)\", \"longitude\":\"\(longitude)\"}"
            fileHandle?.write(data.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
        }
    }
    
    static func getUsersPaths(completion: @escaping handler) {
        var pathNameList: [String:Any] = [:]
        var pathObjList: [Path] = []
        ManipulateUser.getPathNameList { (list) in
            if let path_list = list as? [String:Any] {
                pathNameList = path_list
            }
            
            let databaseRef = Database.database().reference()
            var path: Path?
            
            for name in pathNameList.keys {
                databaseRef.child("Paths").child(name).observeSingleEvent(of: .value) { (snapshot) in
                    path = Path(withsnap: snapshot)
                    pathObjList.append(path!)
                    if pathObjList.count == pathNameList.count {
                        completion(pathObjList)
                    }
                }
            }
        }
    }
    
    static func getAllPublicPaths(completion: @escaping handler) {
        let databaseRef = Database.database().reference()
        databaseRef.child("Paths").observeSingleEvent(of: .value) { (snapshot) in
            if let val = snapshot.value as? Dictionary<String,Any> {
                var path_list: [Path] = []
                for v in val {
                    if let path_dict = v.value as? Dictionary<String,Any> {
                        if let ptype = path_dict["pathType"] as? String {
                            if ptype == "public" {
                                
                                path_list.append(Path(withDict: path_dict))
                                
                                
                            }
                        }
                    }
                }
                completion(path_list)
            }
        }
    }
    
    static func uploadToFireBase(pathId: String) {
        var storageRef = StorageReference()
        guard let url = file_url else{
            return
        }
        do{
            let data: Data = try Data(contentsOf: url)
            let metaData = StorageMetadata()
            metaData.contentType = "text"
            
            let file_name = "PathFiles/\(String(describing: pathId)).txt"
            storageRef = storageRef.child(file_name)
            
            storageRef.putData(data,metadata: metaData) { (data, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "Error")
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    static func getPathFromFile(name: String, completion: @escaping handler){
        var storageRef = StorageReference()
        var path: [CLLocation] = []
        
        let file_name = "PathFiles/\(String(describing: name)).txt"
        storageRef = storageRef.child(file_name)
        storageRef.getData(maxSize: 1024*1024*1024) { (data, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
            else {
                guard let path_data = data else {
                    return
                    }
                do {
                    if let path_json = try JSONSerialization.jsonObject(with: path_data, options: []) as? Dictionary<String,Any> {
                        if let new_path = path_json["path"] as? [Dictionary<String,String>] {
                            for cord in new_path {
                                
                                let lat = Double(cord["latitude"]!)
                                let long = Double(cord["longitude"]!)
                                let c = CLLocation(latitude: lat!, longitude: long!)
                                path.append(c)
                                
                            }
                            completion(path)
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    static func addFollowedUser(path: Path) {
        let user_dict:[String: Any] = [(Auth.auth().currentUser?.uid)!: "id"]
        let databaseRef = Database.database().reference()
        databaseRef.child("Paths").child(path.pathID!).child("FollowedUsers").updateChildValues(user_dict)
    }
    
}
