//
//  CornerRadius+Helper.swift
//  Astro TV
//
//  Created by Harshit Singh on 11/3/17.
//  Copyright © 2017 Harshit Singh. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var ViewCornor: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UIButton {
    
    @IBInspectable var buttonCornor: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UITextField {
    
    @IBInspectable var textFiledCornor: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UIImageView {
    
    @IBInspectable var imageCornor: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
