//
//  CommentsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 24/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
var commentList: [BetComment] = []
class CommentsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BetsRESTServices.getComments()
        notificationCenter.addObserver(self, selector: "getCommentsNotificationReceived:", name: GetCommentBetsTaskFinishedNotificationName, object: nil)
        notificationCenter.addObserver(self, selector: "addCommentNotificationReceived:", name: AddCommentBetsTaskFinishedNotificationName, object: nil)
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refreshMethod:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
    }
    func refreshMethod(refreshControl: UIRefreshControl){
        println("refresh")
        BetsRESTServices.getComments()
        refreshControl.endRefreshing()
    }
    func getCommentsNotificationReceived(notification: NSNotification) {
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
    func addCommentNotificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        let alert = UIAlertView()
        if dict["status"] == Status.Error.rawValue {
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
        }
        else {
            alert.title = "Info"
            alert.message = "Comment created successfully"
            alert.addButtonWithTitle("OK")
            dispatch_async(dispatch_get_main_queue(), {                
                self.tableView.reloadData()
            })
        }
        alert.show()
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentsSegueIdentifier") as! UITableViewCell
        let comment = commentList[indexPath.row]
        cell.textLabel?.text = comment.UserName
        cell.detailTextLabel?.text = NSDateFormatter.localizedStringFromDate(comment.DateCreated, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
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
        if (segue.identifier == "BetCommentSegue") {
            let detailsViewController = segue.destinationViewController as! CommentDetailsViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            let comment = commentList[indexPath!.row]
            detailsViewController.comment = comment
        }
    }
    @IBAction func clickAddCommentButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "New Comment", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Comment"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (action) -> Void in
            let commentTextField = alertController.textFields?[0] as! UITextField
            let newComment = BetComment()
            newComment.Comment = commentTextField.text
            newComment.BetId = currentlyConsiderationBet!.Id
            
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            calendar?.timeZone = NSTimeZone.systemTimeZone()
            let components = NSDateComponents()
            components.calendar = calendar
            components.second = -secondOffsetFromGMT()
            let date = calendar?.dateByAddingComponents(components, toDate: NSDate(), options: nil)
            
            newComment.DateCreated = date!
            BetsRESTServices.addComment(newComment)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
