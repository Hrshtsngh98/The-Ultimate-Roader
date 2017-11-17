//
//  SwiftAlertBar.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/26/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import Foundation
import SwiftMessageBar

var path_color = UIColor(red: 0.0/255.0, green: 255.0/255, blue:230.0/255, alpha: 1.0)
var theme_color = UIColor(red: 0.793583, green: 0.141524, blue: 0.284081, alpha: 1)

var barConfig = MessageBarConfig.Builder()
    .withErrorColor(.black)
    .withSuccessColor(theme_color)
    .withInfoColor(.gray)
    .build()

