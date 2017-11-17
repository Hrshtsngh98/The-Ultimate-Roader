//
//  ShowSpotViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 11/15/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol showSpotProtocol: class{
    func removeSpotMarker(index: Int)
}

class ShowSpotViewController: UIViewController {

    @IBOutlet weak var descTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    var delegate: showSpotProtocol?
    var spot: Path.Spot?
    var spotIndex: Int?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descTypeLabel.text = spot?.cat
        descriptionLabel.text = spot?.spotDescription
        spotImageView.image = spot?.spotImage
        deleteBtn.layer.cornerRadius = 20
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if userId == Auth.auth().currentUser?.uid {
            delegate?.removeSpotMarker(index: spotIndex!)
            dismiss(animated: true, completion: nil)
        } else {
            let alertCont = UIAlertController(title: "Not Allowed", message: "Cannot delete someone else's path.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertCont.addAction(okAction)
            present(alertCont, animated: true, completion: nil)
        }

    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
