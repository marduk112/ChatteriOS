//
//  BetParticipantsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 21/06/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
var betParticipantsList: [BetParticipant] = []
class BetParticipantsViewController : UITableViewController {    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetParticipantsTaskFinishedNotificationName, object: nil)
        BetsRESTServices.getParticipantsRestService()
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refreshMethod:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func refreshMethod(refreshControl: UIRefreshControl){
        BetsRESTServices.getParticipantsRestService()
        refreshControl.endRefreshing()
        println("refresh \(betParticipantsList.count)")
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
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betParticipantsList.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ParticipantSegueIdentifier") as! UITableViewCell
        let bet = betParticipantsList[indexPath.row]
        cell.textLabel?.text = bet.UserName
        if bet.Option! {
            cell.detailTextLabel?.text = "for"
        }
        else {
            cell.detailTextLabel?.text = "against"
        }
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
    }*/
    
    
}