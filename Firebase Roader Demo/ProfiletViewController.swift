//
//  ProfiletViewController.swift
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

class ProfiletViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var firstname_tf: UITextField!
    @IBOutlet weak var lastname_tf: UITextField!
    @IBOutlet weak var city_tf: UITextField!
    @IBOutlet weak var email_tf: UITextField!
    @IBOutlet weak var user_imageV: UIImageView!
    var userImageUrl: String?
    var ref: DatabaseReference?
    var storageRef = StorageReference()
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SETTINGS"
        SVProgressHUD.show()
        imagePickerController.delegate = self
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        SwiftMessageBar.setSharedConfig(barConfig)
        view_info()
    }

    func setupImageSize() {
        user_imageV.layer.cornerRadius = user_imageV.frame.height/2
    }
    
    func view_info() {
        ManipulateUser.sharedinstance.getUser { (u) in
            if let user = u as? User {
                self.firstname_tf.text = user.firstname
                self.lastname_tf.text = user.lastname
                self.email_tf.text = user.email
                self.city_tf.text = user.city
                self.getImage()
            }
        }
    }
    
    func getImage() {
        let user = Auth.auth().currentUser
        
        guard let i_name = user?.uid else {
            return
        }
        
        let imagename = "UserImages/\(String(describing:i_name)).jpeg"
        
        storageRef = storageRef.child(imagename)
        storageRef.getData(maxSize: 5*1024*1024) { (data, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.user_imageV.image = UIImage(data: data!)!
                    self.setupImageSize()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.user_imageV.image = UIImage(named: "DefaultImage")!
                    self.setupImageSize()
                }
                print(error?.localizedDescription ?? "Error")
            }
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func upload_image_action(_ sender: UIButton) {
        if imagePickerController.sourceType == .photoLibrary {
            imagePickerController.sourceType = .photoLibrary
        }
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            user_imageV.image = img
            setupImageSize()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadingImage() {
        guard  let img = user_imageV.image else {
            return
        }
        let data = UIImageJPEGRepresentation(img, 0.8)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        storageRef.putData(data!,metadata: metaData) { (storageMetaData, error) in
            let userImageUrl = storageMetaData?.downloadURL()?.absoluteString
            if let id = Auth.auth().currentUser?.uid {
                self.ref?.child("Users").child(String(describing:id)).updateChildValues(["userImageUrl": userImageUrl])
            }
            if error != nil {
                SVProgressHUD.dismiss()
                print(error?.localizedDescription)
                SwiftMessageBar.showMessageWithTitle("Cannot upload", message: "Something went wrong.", type: .error)
            }
        }
    }
    
    @IBAction func update_info(_ sender: UIButton) {
        SVProgressHUD.show()
        uploadingImage()
        if let user = Auth.auth().currentUser {
            let new_dict = ["FirstName": firstname_tf.text, "LastName": lastname_tf.text,"EmailID": email_tf.text, "City": city_tf.text,"userImageUrl": userImageUrl]
            self.ref?.child("Users").child(user.uid).updateChildValues(new_dict, withCompletionBlock: { (error, dataBaseRef) in
            })
        }
        SVProgressHUD.dismiss()
        SwiftMessageBar.showMessageWithTitle("Success", message: "Profile update successful.", type: .success)
        
    }
    
    @IBAction func change_password(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as?  ResetPasswordViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
