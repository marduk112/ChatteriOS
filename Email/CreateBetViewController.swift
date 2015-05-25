//
//  CreateBetViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 01/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
class CreateBetViewController : UIViewController {
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    @IBOutlet weak var pointsLabel: UITextField!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var resultSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDate = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.timeZone = NSTimeZone.systemTimeZone()
        let components = NSDateComponents()
        components.calendar = calendar
        components.day = 1
        datePicker.minimumDate = calendar?.dateByAddingComponents(components, toDate: currentDate, options: nil)
        setDatetoLabel()
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: CreateBetTaskFinishedNotificationName, object: nil)
    }
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeRight.rawValue
    }
    
    @IBAction func changeDate(sender: AnyObject) {
        setDatetoLabel()
    }
    
    @IBAction func clickCreateBetButton(sender: AnyObject) {
        var result = "false"
        if resultSwitch.on{
            result = "true"
        }
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.timeZone = NSTimeZone.systemTimeZone()
        let components = NSDateComponents()
        components.calendar = calendar
        components.second = -secondOffsetFromGMT()
        let date = datePicker.date
        let endDate = calendar?.dateByAddingComponents(components, toDate: date, options: nil)
        let dateFormatter = NSDateFormatter()
        let startDate = calendar?.dateByAddingComponents(components, toDate: NSDate(), options: nil)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let parameters = ["Title" : titleLabel.text,"DateCreated" : dateFormatter.stringFromDate(startDate!), "EndDate" : dateFormatter.stringFromDate(endDate!), "Description" : descriptionTextView.text,
            "RequiredPoints" : pointsLabel.text, "Result" : result]
        callRestService(parameters)
    }
    func setDatetoLabel(){
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var strDate = dateFormatter.stringFromDate(datePicker.date)
        dateLabel.text = strDate
    }
    func notificationReceived(notification: NSNotification) {
        let dict = notification.userInfo as! [String:String]
        let alert = UIAlertView()
        if dict["status"] == Status.Ok.rawValue {
            alert.title = "Information"
            alert.message = "Bet created successfully"
            alert.addButtonWithTitle("OK")
        }
        else {
            alert.title = "Error"
            alert.message = dict["error"]
            alert.addButtonWithTitle("OK")
        }
        alert.show()
    }
    
    func callRestService(parameters: [String: String!]) -> NSURLSessionDataTask {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/Bets")
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + authData.accessToken, forHTTPHeaderField: "Authorization")
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            if(error != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(CreateBetTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(CreateBetTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                })
            }
        })
        task.resume()
        return task
    }
}