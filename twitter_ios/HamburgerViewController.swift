//
//  HamburgerViewController.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/27/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var menuView: UIView!
    
    var originalLeftMargin: CGFloat!
    
    var isMenuShowing: Bool!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet (oldContentViewController) {
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }
            contentViewController.willMoveToParentViewController(self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isMenuShowing=false
        
        let logo = UIImage(named: "TwitterLogo-1.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onHamburgerMenuClick(sender: AnyObject) {
        originalLeftMargin = leftMarginConstraint.constant
        if(isMenuShowing == true) {
            self.isMenuShowing = false
            self.leftMarginConstraint.constant = 0
        } else {
            self.isMenuShowing = true
            UIView.animateWithDuration(0.5, delay: 0.4,
                options: [.CurveEaseInOut], animations: {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 100
                }, completion: nil)
        }
    }
    
    @IBAction func onComposeButtonClicked(sender: AnyObject) {
        
    }
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == .Began {
            originalLeftMargin = leftMarginConstraint.constant
            
        } else if sender.state == .Changed {
            leftMarginConstraint.constant = originalLeftMargin + translation.x
        } else if sender.state == .Ended {
            UIView.animateWithDuration(0.3, animations: {
                if velocity.x > 0 { //open
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 100
                    self.isMenuShowing = true
                } else { // close
                    self.leftMarginConstraint.constant = 0
                    self.isMenuShowing = false
                }
                self.view.layoutIfNeeded()
            })
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
