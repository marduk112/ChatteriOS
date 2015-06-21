//
//  LogoutViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 20/06/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
class LogoutViewController : UIViewController {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: LogoutTaskFinishedNotificationName, object: nil)
        logout()
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
    private func logout() {
        let alertController = UIAlertController(title: "Logout", message: nil, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)

        let logoutAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in
            BetsRESTServices.logoutRestService()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        if dict["status"] == Status.Ok.rawValue {
            KeychainWrapper.removeObjectForKey("Token")
            KeychainWrapper.removeObjectForKey("UserName")
            KeychainWrapper.removeObjectForKey("ExpiresIn")
            KeychainWrapper.removeObjectForKey("DateCreated")
            authData.accessToken = ""
            let vc: AnyObject? = storyboard?.instantiateInitialViewController()
            showViewController(vc as! UIViewController, sender: nil)
        }
        else {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
