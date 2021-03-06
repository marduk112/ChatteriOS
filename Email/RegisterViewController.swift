//
//  RegisterViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 19/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit

class RegisterViewController : UIViewController{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var registerButton: UIButton!
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: RegisterTaskFinishedNotificationName, object: nil)
        //Reachability.checkConnectedToNetwork()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        let email = emailTextField.text
        let password = passwordTextField.text
        if (email =~ EMAIL_PATTERN) && (password =~ PASSWORD_PATTERN) && (password == confirmPasswordTextField.text) {
            registerButton.enabled = false
            activityIndicator.startAnimating()
            let registration = AuthenticationAndRegistration()
            registration.registration(emailTextField.text, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text)
        }
        else {
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "The request is invalid.\nThe Email field is required.\nThe Password must be at least 6 characters long.(at least one big letter, one special char and one number)"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        registerButton.enabled = true
        activityIndicator.stopAnimating()
        let alert = UIAlertView()
        if dict["status"] == Status.Ok.rawValue {
            alert.title = "OK"
            alert.message = "Registration has done"
            alert.addButtonWithTitle("OK")           
        }
        else {
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
        }
        alert.show()
    }
};