//
//  CommentsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 24/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
class CommentsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    var commentList: [BetComment] = []
    let notificationCenter = NSNotificationCenter.defaultCenter()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        cell.detailTextLabel?.text = comment.Comment
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
    
    func callRestService() {
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/BetComments")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + authData.accessToken, forHTTPHeaderField: "Authorization")
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            let strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(error != nil) {
                println(error.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(GetCommentBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &err) as! NSArray
                for bet in json {
                    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                    calendar?.timeZone = NSTimeZone.systemTimeZone()
                    let components = NSDateComponents()
                    components.calendar = calendar
                    components.second = secondOffsetFromGMT()
                    let temp = bet as! NSDictionary
                    let b = BetComment()
                    if let data:AnyObject? = temp["Id"]{
                        b.Id = data as! Int
                    }
                    if let data:AnyObject? = temp["Commment"]{
                        b.Comment = data as! String
                    }
                    if let data:AnyObject? = temp["DateCreated"]{
                        let date = data as! String
                        b.DateCreated = NSDate.getDateFromJSON(date)
                    }
                    if let data:AnyObject? = temp["UserName"]{
                        b.UserName = data as! String
                    }
                    self.commentList.append(b)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
                self.commentList.sort({ $0.DateCreated.compare($1.DateCreated) == NSComparisonResult.OrderedDescending })
            }
        })
        task.resume()
    }
}
