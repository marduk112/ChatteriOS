//
//  UserInfoViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 21/06/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
var rewardsList: [Reward] = []
class UserInfoViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetRewardsTaskStartNotificationName, object: nil)
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: ChooseRewardsTaskStartNotificationName, object: nil)
        BetsRESTServices.getUserInfoRestService()
        BetsRESTServices.getRewards()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        if dict["status"] == Status.Error.rawValue {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
            alert.show()
        }
        else {
            let userName = KeychainWrapper.stringForKey("UserName")
            userNameLabel.text = "Your name \(userName!)"
            pointsLabel.text = "You have \(authData.points) points"
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardsList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rewardSegueIdentifier") as! UITableViewCell
        let reward = rewardsList[indexPath.row]
        cell.textLabel?.text = reward.Name
        cell.detailTextLabel?.text = "\(reward.Value)"
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 0. Check segue id
        // 1. Get DetailsViewController
        // 2. Get attendee for the cell
        // 3. Assign the attendee to detailsViewController
        if (segue.identifier == "rewardSegueIdentifier") {
            //let detailsViewController = segue.destinationViewController as! CommentDetailsViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            //let comment = rewardsList[indexPath!.row]
            //detailsViewController.comment = comment
            let alertController = UIAlertController(title: "Choose reward", message: nil, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let saveAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.Default) { (action) -> Void in
                let chooseReward = rewardsList[indexPath!.row].Id
                BetsRESTServices.chooseReward(chooseReward)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}