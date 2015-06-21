//
//  BetDetailsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 01/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
class BetDetailsViewController: UIViewController{
    var bet: Bet?
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var requiredPointsLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: ProceedToBetTaskFinishedNotificationName, object: nil)
        descriptionTextView.layer.borderColor = UIColor.blackColor().CGColor
        descriptionTextView.layer.cornerRadius = 15.0
        if let bet = bet {
            topicLabel.text = bet.Title
            dateCreatedLabel.text = "Date created: \((NSDateFormatter.localizedStringFromDate(bet.DateCreated, dateStyle: .ShortStyle, timeStyle: .ShortStyle)))"
            endDateLabel.text = "End date: \(NSDateFormatter.localizedStringFromDate(bet.EndDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
            descriptionTextView.text = "Description:\n" + bet.Description
            requiredPointsLabel.text = "Required points: \(bet.RequiredPoints)"
            ownerLabel.text = "Owner: \(bet.User.UserName)"
            currentlyConsiderationBet = bet
        }        
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        let alert = UIAlertView()
        if dict["status"] == Status.Error.rawValue {
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clickProceedToBetButton(sender: AnyObject) {
        if currentlyConsiderationBet?.EndDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            return
        }
        var parameters = ["BetId" : String(currentlyConsiderationBet!.Id)]
        let alertController = UIAlertController(title: "Proceed to bet", message: "for or against", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let forAction = UIAlertAction(title: "For", style: UIAlertActionStyle.Default) { (action) -> Void in
            parameters["Option"] = "true"
            self.proceedToBet(parameters)
        }
        let againstAction = UIAlertAction(title: "Against", style: UIAlertActionStyle.Default) { (action) -> Void in
            parameters["Option"] = "false"
            self.proceedToBet(parameters)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(againstAction)
        alertController.addAction(forAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func proceedToBet(parameters: [String : String]) {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/BetParticipants")
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            if(error != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(ProceedToBetTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(ProceedToBetTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                })
            }
        })
        task.resume()       
    }
}
