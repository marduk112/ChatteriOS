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
import RealmSwift
var betParticipantsList: [BetParticipant] = []
class BetParticipantsViewController : UITableViewController {    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetParticipantsTaskFinishedNotificationName, object: nil)
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: ProceedToBetTaskFinishedNotificationName, object: nil)
        /*let list = Realm().objects(BetParticipant)
        for b in list {
            betParticipantsList.append(b)
        }    */    
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
    @IBAction func addParticipantButton(sender: AnyObject) {
        let userName = KeychainWrapper.stringForKey("UserName")!
        if (currentlyConsiderationBet?.EndDate.compare(NSDate()) == NSComparisonResult.OrderedAscending && userName != currentlyConsiderationBet?.User.UserName) {
            var parameters = ["BetId" : String(currentlyConsiderationBet!.Id)]
            let alertController = UIAlertController(title: "Proceed to bet", message: "for or against", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let forAction = UIAlertAction(title: "For", style: UIAlertActionStyle.Default) { (action) -> Void in
                parameters["Option"] = "true"
                BetsRESTServices.proceedToBet(parameters)
            }
            let againstAction = UIAlertAction(title: "Against", style: UIAlertActionStyle.Default) { (action) -> Void in
                parameters["Option"] = "false"
                BetsRESTServices.proceedToBet(parameters)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(againstAction)
            alertController.addAction(forAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertView()
            alert.title = "Info"
            alert.message = "You cannot procced to your own bet"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
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
        if bet.Option {
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