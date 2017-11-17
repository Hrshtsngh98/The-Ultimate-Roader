//
//  ShareLocViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/27/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import MessageUI

class ShareLocViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
    var cord_val = ""
    @IBOutlet weak var share_table: UITableView!
    @IBOutlet weak var cord_label: UILabel!
    var share_list: [ShareType] = [ShareType("Message"), ShareType("Whatsapp"), ShareType("Copy")]
    override func viewDidLoad() {
        super.viewDidLoad()
        share_table.dataSource = self
        cord_label.text = cord_val
        share_table.tableFooterView = UIView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return share_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "share_cell", for: indexPath)
        let shareT = share_list[indexPath.row]
        cell.textLabel?.text = shareT.name?.rawValue
        cell.imageView?.image = UIImage(named: shareT.imageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Hey, my loacation is "+cord_val
                //controller.recipients = ["+13125360197"]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                let controller = UIAlertController(title: "Alert", message: "Device not supported", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                controller.addAction(action)
                present(controller, animated: true, completion: nil)
            }
        } else if indexPath.row == 1 {
            let msg = "Hey, my loacation is "+cord_val
            let urlWhats = "whatsapp://send?text=\(msg)"
            
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                if let whatsappURL = NSURL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                        UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
                    } else {
                        let controller = UIAlertController(title: "Install Whatsapp", message: "", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        controller.addAction(action)
                        present(controller, animated: true, completion: nil)
                    }
                }
            }
        } else if indexPath.row == 2 {
            let controller = UIAlertController(title: "Copied", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            controller.addAction(action)
            present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func cancel_action(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
