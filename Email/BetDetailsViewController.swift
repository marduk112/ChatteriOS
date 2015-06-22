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
        
    }
    
    
}
