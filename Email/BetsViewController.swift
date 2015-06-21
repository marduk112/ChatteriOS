//
//  BetsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 30/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
import Foundation
import SwiftKeychainWrapper

var betList: [Bet] = []
class BetsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        //KeychainWrapper.removeObjectForKey("Token")
        //if !KeychainWrapper.hasValueForKey("Token") {        
        //}
        //else {
        BetsRESTServices.getBetsRestService()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refreshMethod:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetBetsTaskFinishedNotificationName, object: nil)
        //}
    }
    func refreshMethod(refreshControl: UIRefreshControl){
        println("refresh")
        BetsRESTServices.getBetsRestService()
        refreshControl.endRefreshing()
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
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }        
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BetsSegueIdentifier") as! UITableViewCell
        let bet = betList[indexPath.row]
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
            let bet = betList[indexPath!.row]
            detailsViewController.bet = bet
        }
    }
   
}
