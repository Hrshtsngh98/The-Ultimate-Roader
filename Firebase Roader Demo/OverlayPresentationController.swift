//
//  OverlayPresentationController.swift
//  Present
//
//  Created by Vlad Gorbenko on 4/20/16.
//  Copyright © 2016 Vlad Gorbenko. All rights reserved.
//

import UIKit

class OverlayPresentationController: UIPresentationController {
    
    var inset = 0.0
    
    fileprivate let dimmingView = UIView()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(OverlayPresentationController.dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dimmingViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func presentationTransitionWillBegin() {
        if let containerView = self.containerView {
            dimmingView.frame = containerView.bounds
            dimmingView.alpha = 0.0
            self.containerView?.addSubview(dimmingView)
        }
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.0
        }, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView : CGRect {
        if let containerView = self.containerView {
            var size = CGSize.zero
            for view in self.presentedViewController.view.subviews {
                var viewSize = CGSize.zero
                if view is UITableView {
                    viewSize = view.sizeThatFits(self.presentedViewController.view.bounds.size)
                } else {
                    viewSize = view.systemLayoutSizeFitting(self.presentedViewController.view.bounds.size)
                }
                if viewSize.width > 0 {
                    size.height += viewSize.height
                }
            }
            size.width = containerView.bounds.insetBy(dx: CGFloat(self.inset), dy: 0).width
            size.height = min(size.height, containerView.bounds.insetBy(dx: CGFloat(self.inset), dy: CGFloat(self.inset)).height)
            let limitOrigin = containerView.bounds.insetBy(dx: CGFloat(self.inset), dy: CGFloat(self.inset)).origin
            if inset == 30 {
                let center = CGPoint(x: limitOrigin.x + size.width/2, y: limitOrigin.y + size.height/2)
                let origin = CGPoint(x: limitOrigin.x, y: limitOrigin.y + self.containerView!.center.y - center.y)
                return CGRect(origin: origin, size: size)


            }else{
                size.height = 278
                let center = CGPoint(x: limitOrigin.x + size.width/2, y: limitOrigin.y + size.height)
                let origin = CGPoint(x: limitOrigin.x, y: limitOrigin.y + self.containerView!.frame.size.height - center.y)
                return CGRect(origin: origin, size: size)

                
            }
            
        }
        return super.frameOfPresentedViewInContainerView
    }
    
    
}
