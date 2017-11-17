//
//  MarkSpotViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 11/11/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import UITextView_Placeholder

protocol MarkSpotProtocol: class {
    func addSpotMarker(spot: Path.Spot)
}

class MarkSpotViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var delegate: MarkSpotProtocol?
    var loc: CLLocation?
    var spot: Path.Spot?
    var storageRef = StorageReference()
    var ref = Database.database().reference()
    
    
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet weak var spotDescriptionTf: UITextView!
    @IBOutlet weak var spotImageView: UIImageView!
    
    var imagePickerCont = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add general note."
        imagePickerCont.delegate = self
        typePickerView.delegate = self
        spot = Path.Spot()
        spot?.cat = "General"
        spot?.category = .General
        spot?.location = loc
        typePickerView.layer.borderColor = UIColor.white.cgColor
        typePickerView.layer.borderWidth = 2
        typePickerView.layer.cornerRadius = 10
        spotDescriptionTf.placeholder = "Description"
        spotDescriptionTf.placeholderColor = UIColor.white
    }
    

    @IBAction func pickImageAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: "Select", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerCont.sourceType = .camera
            self.present(self.imagePickerCont, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Photo Gallery", style: .default) { (action) in
            self.imagePickerCont.sourceType = .photoLibrary
            self.present(self.imagePickerCont, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addSpotAction(_ sender: UIButton) {
        
        spot?.spotDescription = spotDescriptionTf.text
        
        if let image = spotImageView.image {
            spot?.spotImage = image
        }
        delegate?.addSpotMarker(spot: spot!)
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            spotImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 1 {
            return "Warning"
        } else if row == 2 {
            return "Recommendation"
        } else {
            return "General"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var str = ""
        if row == 1 {
            str = "Warning"
        } else if row == 2 {
            str = "Recommendation"
        } else {
            str = "General"
        }
        
        let type = NSAttributedString.init(string: str, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        return type
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        spot?.category = Path.Spot.Category.allValues[row]
        spot?.cat = spot?.category.rawValue
        title = "Add " + (spot?.cat)! + " note."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
