//
//  MenuViewController.swift
//  twitter_ios
//
//  Created by Priscilla Lok on 2/27/16.
//  Copyright © 2016 Priscilla Lok. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    
    @IBOutlet weak var tableView: UITableView!
    
    private var profileNavigationController:UIViewController!
    private var homeTimelineNavigationController:UIViewController!
    private var mentionsNavigationController:UIViewController!
    
    var viewControllers: [UIViewController] = []
    
    var hamburgerViewController: HamburgerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        profileNavigationController = storyboard.instantiateViewControllerWithIdentifier("profileNavigationController")
        homeTimelineNavigationController = storyboard.instantiateViewControllerWithIdentifier("homeTimelineNavigationController")
        mentionsNavigationController = storyboard.instantiateViewControllerWithIdentifier("mentionsNavigationController")
        
        viewControllers.append(profileNavigationController)
        viewControllers.append(homeTimelineNavigationController)
        viewControllers.append(mentionsNavigationController)
        
        hamburgerViewController.contentViewController = homeTimelineNavigationController
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        
        let titles = ["Profile", "Home Timeline", "Mentions", "Logout"]
        
        cell.menuTitleLabel.text = titles[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 3 {
            User.currentUser?.logout()
        } else {
            hamburgerViewController.contentViewController = viewControllers[indexPath.row]
            if indexPath.row == 0 {
                let navigationController = hamburgerViewController.contentViewController as! UINavigationController
                let profileViewController = navigationController.topViewController as! ProfileViewController
                
                profileViewController.currUser = User.currentUser!
            }
            hamburgerViewController.isMenuShowing = false
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
