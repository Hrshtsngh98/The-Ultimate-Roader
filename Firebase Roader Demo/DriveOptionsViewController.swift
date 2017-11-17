//
//  DriveOptionsViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/23/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import SwiftMessageBar

class DriveOptionsViewController: BaseViewController {

    @IBOutlet weak var drive_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DRIVE OPTIONS"
        SwiftMessageBar.setSharedConfig(barConfig)
        drive_btn.layer.cornerRadius = drive_btn.frame.height/2
        // Do any additional setup after loading the view.
    }
    
    @IBAction func driven_list_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AllPathViewController") as? AllPathViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func drive_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "GoogleMapViewController") as? GoogleMapViewController
        {
            SwiftMessageBar.showMessageWithTitle("See Map", message: "Start Driving.", type: .info)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
