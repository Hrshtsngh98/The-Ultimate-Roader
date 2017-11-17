//
//  SignUpViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/17/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import SwiftMessageBar

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var firstname_tf: UITextField!
    @IBOutlet weak var lastname_tf: UITextField!
    @IBOutlet weak var email_tf: UITextField!
    @IBOutlet weak var city_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    @IBOutlet weak var confirmpass_tf: UITextField!
    @IBOutlet weak var user_imageV: UIImageView!
    var userImageUrl: String?
    var ref: DatabaseReference?
    var storageRef = StorageReference()
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        SwiftMessageBar.setSharedConfig(barConfig)
        setupImageSize()
    }
    
    func setupImageSize() {
        user_imageV.layer.cornerRadius = user_imageV.frame.height/2
    }

    @IBAction func sign_up_action(_ sender: UIButton) {
        if firstname_tf.text?.count == 0 {
            popUpAlert(mess: "First Name")
        }
        else if lastname_tf.text?.count == 0 {
            popUpAlert(mess: "Last Name")
        }
        else if email_tf.text?.count == 0 {
            popUpAlert(mess: "Email")
        }
        else if city_tf.text?.count == 0 {
            popUpAlert(mess: "City")
        }
        else if password_tf.text?.count == 0 {
            popUpAlert(mess: "Password")
        }else  if confirmpass_tf.text?.count == 0 {
            popUpAlert(mess: "Confirm Password")
        } else if password_tf.text != confirmpass_tf.text {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Password do not match!", type: .error)
        }else {
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: email_tf.text!, password: password_tf.text!) { (user, error) in
                if error == nil {
                    let userDict = ["FirstName": self.firstname_tf.text, "LastName":self.lastname_tf.text, "Password": self.password_tf.text,"UserId": user?.uid, "EmailID": self.email_tf.text, "City": self.city_tf.text, "userImageUrl": self.userImageUrl]
                    if let id = user?.uid {
                        self.ref?.child("Users").child(id).updateChildValues(userDict, withCompletionBlock: { (error, dataBaseRef) in
                            if error == nil {
                                self.uploadingImage()
                                SwiftMessageBar.showMessageWithTitle("Congrats!!", message: "Sign Up successful.", type: .success)
                            }
                            else {
                                print(error?.localizedDescription ?? "Error")
                                SwiftMessageBar.showMessageWithTitle("Error", message: "Something went wrong.", type: .error)
                            }
                        })
                    }
                    SVProgressHUD.dismiss()
                }else{
                    print(error?.localizedDescription ?? "Error")
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func uploadingImage() {
        guard  let img = user_imageV.image else {
            return
        }
        let data = UIImageJPEGRepresentation(img, 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        if let id = Auth.auth().currentUser {
            let imagename = "UserImages/\(String(describing:id.uid)).jpeg"
            storageRef = storageRef.child(imagename)
            storageRef.putData(data!,metadata: metaData) { (storageMetaData, error) in
                let userImageUrl = storageMetaData?.downloadURL()?.absoluteString
                self.ref?.child("Users").child(String(describing:id.uid)).updateChildValues(["userImageUrl": userImageUrl])
                if error != nil {
                    SVProgressHUD.dismiss()
                    print(error?.localizedDescription)
                    SwiftMessageBar.showMessageWithTitle("Cannot upload", message: "Something went wrong.", type: .error)
                }
            }
            
        }
    }
    
    @IBAction func cancel_btn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func select_Image(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: "Select", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Photo Gallery", style: .default) { (action) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            user_imageV.image = img
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func popUpAlert(mess: String) {
        let alert = UIAlertController(title: "Alert", message: "\(mess) not present", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
