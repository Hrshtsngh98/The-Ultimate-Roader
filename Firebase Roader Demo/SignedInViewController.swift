//
//  SignedInViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/23/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import SwiftMessageBar

class SignedInViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOME"
        SwiftMessageBar.setSharedConfig(barConfig)
        // Do any additional setup after loading the view.
    }

    @IBAction func setting_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfiletViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func drive_option_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "DriveOptionsViewController") as? DriveOptionsViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func information_btn_action(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "InformationViewController") as? InformationViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func Signout_action(_ sender: UIButton) {
        SVProgressHUD.show()
        do {
            try Auth.auth().signOut()
            SwiftMessageBar.showMessageWithTitle("Sign Out", message: "Sign out successful.", type: .success)
            dismiss(animated: true, completion: nil)
        }
        catch {
            SwiftMessageBar.showMessageWithTitle("Problem!!", message: "Something went wrong.", type: .error)
            print(error.localizedDescription)
        }
        SVProgressHUD.dismiss()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
