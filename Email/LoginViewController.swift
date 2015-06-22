//
//  ViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 18/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: AuthTaskFinishedNotificationName, object: nil)
        KeychainWrapper.removeObjectForKey("Token")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func clickLoginButton(sender: AnyObject) {
        
        if KeychainWrapper.hasValueForKey("Token")  {
            let timeout = KeychainWrapper.stringForKey("ExpiresIn")
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
            calendar?.timeZone = NSTimeZone.systemTimeZone()
            let components = NSDateComponents()
            components.calendar = calendar
            components.second = timeout!.toInt()!
            let dateCreated = NSDate.getDateFromJSON(KeychainWrapper.stringForKey("DateCreated")!)
            let endDate = calendar?.dateByAddingComponents(components, toDate: dateCreated, options: nil)
            if NSDate().compare(endDate!) == NSComparisonResult.OrderedAscending {
                let vc: AnyObject? = storyboard?.instantiateViewControllerWithIdentifier("TabBarBets")
                showViewController(vc as! UIViewController, sender: nil)
            }
        }
        let email = emailTextField.text
        let password = passwordTextField.text
        if (email =~ EMAIL_PATTERN) && (password =~ PASSWORD_PATTERN) {
            enableButton(false)
            activityIndicator.startAnimating()
            let auth = AuthenticationAndRegistration()
            auth.authentication(emailTextField.text, password: passwordTextField.text)
            println("s")
        }
        else {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "The request is invalid.\nThe Email field is required.\nThe Password must be at least 6 characters long."
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        enableButton(true)
        activityIndicator.stopAnimating()
        if dict["status"] == Status.Ok.rawValue {
            authData.userName = emailTextField.text
            let vc: AnyObject? = storyboard?.instantiateViewControllerWithIdentifier("TabBarBets")            
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
    
    private func enableButton(isEnabled: Bool) {
        loginButton.enabled = isEnabled
        registerButton.enabled = isEnabled
    }
}

