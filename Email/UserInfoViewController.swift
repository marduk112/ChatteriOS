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
class UserInfoViewController : UIViewController {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetUserPointsTaskStartNotificationName, object: nil)
        BetsRESTServices.getUserInfoRestService()
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
}