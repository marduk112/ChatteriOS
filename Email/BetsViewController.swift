//
//  BetsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 30/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import UIKit
import Foundation
var betList: [Bet] = []
class BetsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    override func viewDidLoad() {
        super.viewDidLoad()
        //Reachability.checkConnectedToNetwork()
        //if Reachability.isConnectedToNetwork() {
            callRestService()
        //}
        notificationCenter.addObserver(self, selector: "notificationReceived:", name: GetBetsTaskFinishedNotificationName, object: nil)
        /*let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "clickRefreshButton")
        navigationItem.rightBarButtonItem = refreshButton*/
        
    }
    func clickRefreshButton() {
        callRestService()
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
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return betList.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BetsSegueIdentifier") as! UITableViewCell
        let bet = betList[indexPath.row]
        cell.textLabel?.text = bet.Title
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
        if (segue.identifier == "ShowBetDetails") {
            let detailsViewController = segue.destinationViewController as! BetDetailsViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            let bet = betList[indexPath!.row]
            detailsViewController.bet = bet
        }
    }
   
        func callRestService() {
            let request : NSMutableURLRequest = NSMutableURLRequest()
            request.URL = NSURL(string: restServiceUrl + "/api/Bets")
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
                        NSNotificationCenter.defaultCenter().postNotificationName(GetBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
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
                        let b = Bet()
                        if let data: AnyObject? = temp["Title"] {
                            b.Title = data as! String
                        }
                        if let data: AnyObject? = temp["Id"] {
                            b.Id = data as! Int
                        }
                        if let data: AnyObject? = temp["DateCreated"] {
                            b.DateCreated = NSDate.getDateFromJSON(data as! String)                            
                            b.DateCreated = calendar!.dateByAddingComponents(components, toDate: b.DateCreated, options: nil)!
                        }
                        if let data: AnyObject? = temp["EndDate"] {
                            b.EndDate = NSDate.getDateFromJSON(data as! String)
                            b.EndDate = calendar!.dateByAddingComponents(components, toDate: b.EndDate, options: nil)!
                        }
                        if let data: AnyObject? = temp["Description"] {
                            b.Description = data as! String
                        }
                        if let data: AnyObject? = temp["RequiredPoints"] {
                            b.RequiredPoints = data as! Int
                        }
                        if let data: AnyObject? = temp["Result"] {
                            b.Result = data as! Bool
                        }
                        if let data: AnyObject? = temp["UserName"] {
                            b.User.UserName = data as! String
                        }
                        betList.append(b)
                        dispatch_async(dispatch_get_main_queue(), {                            
                            self.tableView.reloadData()
                        })
                    }
                    betList.sort({ $0.DateCreated.compare($1.DateCreated) == NSComparisonResult.OrderedDescending })
                }
            })
            task.resume()          
        }
}
