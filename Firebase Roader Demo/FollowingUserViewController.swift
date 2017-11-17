//
//  FollowingUserViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/31/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class FollowingUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var following_user_table: UITableView!
    
    var follower_list: [User] = []
    var path: Path?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FOLLOWING USERS"
        following_user_table.dataSource = self
        SVProgressHUD.show()
        getUserList()
    }
    
    func getUserList() {
        ManipulateUser.getUserForpath(path: path!) { (userObjList) in
            if let userlist = userObjList as? [User] {
                self.follower_list = userlist
                DispatchQueue.main.async {
                    self.following_user_table.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return follower_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "follower_cell") as? FollowingUserTableViewCell
        let user = follower_list[indexPath.row]
        cell?.username_label.text = user.firstname! + " " + user.lastname!
        cell?.useremail_label.text = user.email
        cell?.usercity_label.text = user.city
        cell?.path_count_label.text = "\(user.pathList.keys.count)"
        
        if let url_str = user.userImageUrl {
            let url = URL(string: url_str)
            let img_data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                cell?.user_imageV.image = UIImage(data: img_data!)
            }
        }
        else {
            DispatchQueue.main.async {
               cell?.user_imageV.image = UIImage(named: "DefaultImage")
            }
        }
        return cell!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
