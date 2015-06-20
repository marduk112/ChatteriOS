//
//  MyBetsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 30/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
import Foundation
var myBetList: [Bet] = []
class MyBetsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        //Reachability.checkConnectedToNetwork()
        //if Reachability.isConnectedToNetwork() {
        getMyBet()
        //}
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetMyBetsTaskFinishedNotificationName, object: nil)
    }
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        let alert = UIAlertView()
        if dict["status"] == Status.Error.rawValue {
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
        }
        alert.show()
    }
    deinit {
        notificationCenter.removeObserver(self)
    }   
    @IBAction func clickOnRefreshButton(sender: AnyObject) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myBetList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyBetsSegueIdentifier") as! UITableViewCell
        let bet = myBetList[indexPath.row]
        cell.textLabel?.text = bet.Title
        cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(bet.EndDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
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
        if (segue.identifier == "ShowBetDetails") {           
            let detailsViewController = segue.destinationViewController as! BetDetailsViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            let bet = myBetList[indexPath!.row]
            detailsViewController.bet = bet
        }
    }
    
    private func getMyBet() {
        myBetList = betList.filter({ el in el.User.UserName == authData.userName})
    }
    
}
