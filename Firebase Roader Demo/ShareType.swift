//
//  ShareType.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/27/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation

class ShareType {
    var name: ShareApp?
    var imageName: String
    
    init(_ shareName: String) {
        name = ShareApp(rawValue: shareName)
        imageName = shareName
    }
    
    enum ShareApp: String {
        case Whatsapp = "Whatsapp"
        case Message = "Message"
        case Copy = "Copy"
        
        static let allValues: [ShareApp] = [.Whatsapp, .Message, .Copy]
    }
}
