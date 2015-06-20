//
//  BetDetailsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 01/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
class BetDetailsViewController: UIViewController{
    var bet: Bet?
    
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var requiredPointsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bet = bet {
            topicLabel.text = bet.Title
            dateCreatedLabel.text = "Date created: \(bet.DateCreated)"
            endDateLabel.text = "End date: \(bet.EndDate)"
            descriptionLabel.text = "Description:\n" + bet.Description
            requiredPointsLabel.text = "Required points: \(bet.RequiredPoints)"
            ownerLabel.text = "Owner: \(bet.User.UserName)"            
        }        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickToBetButton(sender: AnyObject) {
        let alert = UIAlertController()
        alert.title = "Question"
        alert.message = "Are you sure?"      
        let addAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
            
        })
    }
    
}