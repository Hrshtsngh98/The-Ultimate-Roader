//
//  ModifyPathDetailsViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/24/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit

class ModifyPathDetailsViewController: UIViewController, UITextFieldDelegate {

    var path: Path?
    @IBOutlet weak var pathname_tf: UITextField!
    @IBOutlet weak var easy_imgV: UIImageView!
    @IBOutlet weak var med_imgV: UIImageView!
    @IBOutlet weak var hard_imgV: UIImageView!
    @IBOutlet weak var private_btn: UIButton!
    @IBOutlet weak var public_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pathname_tf.text = path?.pathName
        pub_pri_button_setup()
    }
    
    func pub_pri_button_setup() {
        private_btn.backgroundColor = UIColor.darkGray
        public_btn.backgroundColor = UIColor.darkGray
        private_btn.layer.cornerRadius = private_btn.frame.height/2
        public_btn.layer.cornerRadius = private_btn.frame.height/2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        path?.pathName = textField.text
        return true
    }

    @IBAction func easy_btn_action(_ sender: UIButton) {
        easy_imgV.image = UIImage(named:"EasyPathModeIconSec")
        med_imgV.image = UIImage(named:"MediumPathModeIcon")
        hard_imgV.image = UIImage(named:"HardPathmodeIcon")
        path?.difficulty = .Easy
    }
    
    @IBAction func medium_btn_action(_ sender: UIButton) {
        easy_imgV.image = UIImage(named:"EasyPathModeIcon")
        med_imgV.image = UIImage(named:"MediumPathModeIconSec")
        hard_imgV.image = UIImage(named:"HardPathmodeIcon")
        path?.difficulty = .Medium
    }
    
    @IBAction func hard_btn_action(_ sender: UIButton) {
        easy_imgV.image = UIImage(named:"EasyPathModeIcon")
        med_imgV.image = UIImage(named:"MediumPathModeIcon")
        hard_imgV.image = UIImage(named:"HardPathmodeIconSec")
        path?.difficulty = .Hard
    }
    
    @IBAction func private_path_btn(_ sender: UIButton) {
        path?.pathType = .Private
        private_btn.backgroundColor = theme_color
        public_btn.backgroundColor = UIColor.darkGray
    }
    
    @IBAction func public_path_btn(_ sender: UIButton) {
        path?.pathType = .Public
        public_btn.backgroundColor = theme_color
        private_btn.backgroundColor = UIColor.darkGray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
