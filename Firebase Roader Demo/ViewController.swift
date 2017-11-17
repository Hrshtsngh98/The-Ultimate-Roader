//
//  ViewController.swift
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
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class ViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var username_tf: UITextField!
    @IBOutlet weak var password_tf: UITextField!
    @IBOutlet weak var verification_tf: UITextField!
    
    @IBOutlet weak var login_btn_view: UIView!
    var ref: DatabaseReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        SwiftMessageBar.setSharedConfig(barConfig)
        print((try? FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)))
        
        
        let google_btn = GIDSignInButton()
        GIDSignIn.sharedInstance().uiDelegate = self
        google_btn.frame = CGRect(x: -60, y: 0, width: 80, height: 28)
        login_btn_view.addSubview(google_btn)
        
        let facebookloginButton = FBSDKLoginButton()
        facebookloginButton.delegate = self
        facebookloginButton.frame = CGRect(x: 60, y: 4, width: google_btn.frame.width-5, height: google_btn.frame.height - 7)
        login_btn_view.addSubview(facebookloginButton)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let err = error{
            print(err.localizedDescription)
            return
        }
        
        if result.isCancelled == false{
            print(result.token.tokenString)
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential ) { (user, error) in
            if let err = error {
                print(err)
            } else {
                self.LoginWithFacebook()
                SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
                self.present(controller!, animated: true, completion: nil)
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    @IBAction func phonesigninAction(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Send Code" {
            if let phone_num = username_tf.text {
                PhoneAuthProvider.provider().verifyPhoneNumber(phone_num, uiDelegate: nil) { (verificationID, error) in
                    Auth.auth().languageCode = "en"
                    if let error = error {
                        SwiftMessageBar.showMessageWithTitle("Error", message: error.localizedDescription, type: .error)
                        return
                    } else {
                        
                        sender.titleLabel?.text = "Verify"
                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                    }
                }
            } else {
                SwiftMessageBar.showMessageWithTitle("Enter phone number", message: "", type: .error)
            }
            
        } else if sender.titleLabel?.text == "Verify" {
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: verification_tf.text!)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    return
                }
                SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
                self.present(controller!, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        signInwithUserandPass()
        return true
    }
    @IBAction func sign_in_action(_ sender: UIButton) {
        signInwithUserandPass()
    }
    
    func signInwithUserandPass() {
        guard let user = username_tf.text, let pass = password_tf.text else {
            return
        }

        if user.characters.count == 0 || pass.characters.count == 0 {
            SwiftMessageBar.showMessageWithTitle("Error", message: "Enter Username and Password", type: .error)
        } else {
            
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: user, password: pass) { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    SwiftMessageBar.showMessageWithTitle("Error", message: "Username or Password wrong", type: .error)
                } else {
                    SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
                    self.present(controller!, animated: true, completion: nil)
                }
                self.username_tf.text = ""
                self.password_tf.text = ""
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                return
            }
            
            if let uid = Auth.auth().currentUser?.uid {
                let userDict = ["FirstName": user?.displayName, "UserId": uid, "EmailID": user?.email]
                
                self.ref?.child("Users").child(uid).updateChildValues(userDict, withCompletionBlock: { (error, dataBaseRef) in
                    if error == nil {
                        SwiftMessageBar.showMessageWithTitle("Congrats!!", message: "Sign Up successful.", type: .success)
                    }
                    else {
                        print(error?.localizedDescription ?? "Error")
                        SwiftMessageBar.showMessageWithTitle("Error", message: "Something went wrong.", type: .error)
                    }
                })
            }
            
            SwiftMessageBar.showMessageWithTitle("Success", message: "Login Successful", type: .success)
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
            self.present(controller!, animated: true, completion: nil)
        }
    }
    
    @IBAction func sign_up_action(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        present(controller!, animated: true, completion: nil)
    }
    
    func LoginWithFacebook() {
        let logIn = FBSDKLoginManager()
        logIn.logIn(withReadPermissions: ["public_profile","email"], from: self, handler: { (result, error) in
            
            if error == nil && result?.isCancelled == false{
                
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name"]).start(completionHandler: { (connection, result, error) in
                    if let res = result as? [String:Any] {
                        var firstname = "", lastname = "", email = ""
                        if let fname = res["first_name"] as? String,let lname = res["last_name"] as? String,let em = res["email"] as? String {
                            firstname = fname
                            lastname = lname
                            email = em
                        
                            if let uid = Auth.auth().currentUser?.uid {
                            let userDict = ["FirstName": fname, "LastName":lname, "UserId": uid, "EmailID": email]
                            
                                self.ref?.child("Users").child(uid).updateChildValues(userDict, withCompletionBlock: { (error, dataBaseRef) in
                                    if error == nil {
                                        SwiftMessageBar.showMessageWithTitle("Congrats!!", message: "Sign Up successful.", type: .success)
                                    }
                                    else {
                                        print(error?.localizedDescription ?? "Error")
                                        SwiftMessageBar.showMessageWithTitle("Error", message: "Something went wrong.", type: .error)
                                    }
                                })
                            }
                        }
                    }
                })
            }
        })
    }
    
    
    @IBAction func reset_password(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: "hrshtsngh98@gmail.com") { (error) in
            
            if error == nil {
                SwiftMessageBar.showMessageWithTitle("Success", message: "Mail Sent", type: .success)
            }
            else {
                print(error?.localizedDescription ?? "Error")
                SwiftMessageBar.showMessageWithTitle("Error", message: error?.localizedDescription, type: .error)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

