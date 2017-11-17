//
//  AllPathViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/22/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation

class AllPathViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var path_list: [Path] = []
    var permanent_path_list: [Path] = []
    @IBOutlet weak var path_table: UITableView!
    @IBOutlet weak var search_bar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersPaths()
        title = "DRIVE LIST"
        path_table.tableFooterView = UIView()
        path_table.dataSource = self
        //path_table.rowHeight = 200
    }
    
    func getUsersPaths() {
        SVProgressHUD.show()
        ManagePath.getUsersPaths { (all_path) in
            if let paths = all_path as? [Path] {
                self.path_list = paths
                self.permanent_path_list = paths
                DispatchQueue.main.async {
                    self.path_table.reloadData()
                }
            } else {
                self.path_list = []
            }
            
        }
        SVProgressHUD.dismiss()
    }
    
    func getAllPublicPaths() {
        SVProgressHUD.show()
        ManagePath.getAllPublicPaths{ (all_path) in
            if let paths = all_path as? [Path] {
                self.path_list = paths
                self.permanent_path_list = paths
                DispatchQueue.main.async {
                    self.path_table.reloadData()
                }
            } else {
                self.path_list = []
            }
        }
        SVProgressHUD.dismiss()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return path_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "path_cell") as? PathTableViewCell
        let path = path_list[indexPath.row]
        cell?.path_name_label.text = path.pathName
        cell?.distance_label.text = "\(String(format: "%.01f", Double(path.distance ?? "0")!)) km"
        cell?.time_label.text = "\(path.time ?? "1") mins"
        cell?.date_label.text = path.createdDate
        cell?.user_count_label.text = "\(path.followed_user.keys.count)"
        
        cell?.user_count_btn.tag = indexPath.row
        cell?.user_count_btn.addTarget(self, action: #selector(openFollowerList), for: .touchUpInside)
        
        if path.difficulty.rawValue == "hard"{
            cell?.mode_imageV.image = UIImage(named: "HardPathmodeIconSec")
        } else if path.difficulty.rawValue == "medium"{
            cell?.mode_imageV.image = UIImage(named: "MediumPathModeIconSec")
        } else if path.difficulty.rawValue == "easy" {
            cell?.mode_imageV.image = UIImage(named: "EasyPathModeIconSec")
        }
        return cell!
    }
    
    @objc func openFollowerList(sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "FollowingUserViewController") as? FollowingUserViewController {
            controller.path = path_list[sender.tag]
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let new_path = path_list[indexPath.row]
        guard let fileName = new_path.pathID else {
            return
        }
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SelectedPathViewController") as? SelectedPathViewController {
            controller.path = new_path
            controller.file_name = fileName
            controller.name = new_path.pathName!
        self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        path_list = permanent_path_list
        if !(searchBar.text?.isEmpty)! {
            path_list = path_list.filter({($0.pathName?.lowercased().contains(searchText.lowercased()))!})
        }
        path_table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        permanent_path_list = []
        path_list = []
        if selectedScope == 0 {
            getUsersPaths()
        }
        else if selectedScope == 1 {
            getAllPublicPaths()
        }

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search_bar.text = ""
        path_list = permanent_path_list
        searchBar.resignFirstResponder()
        path_table.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
