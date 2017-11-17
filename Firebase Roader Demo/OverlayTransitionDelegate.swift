//
//  OverlayTransitionDelegate.swift
//  Present
//
//  Created by Vlad Gorbenko on 4/20/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

class OverlayTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return OverlayPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
