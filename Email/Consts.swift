//
//  Consts.swift
//  Email
//
//  Created by Szymon Wójcik on 25/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
class AuthenticationData {
    var accessToken = ""
    var tokenType = ""
    var expiresIn = 0
    var userName = ""
}
let authData = AuthenticationData()
let restServiceUrl = "http://chatterrest.apphb.com"
let AuthTaskFinishedNotificationName = "AuthTaskFinishedNotificationName"
let RegisterTaskFinishedNotificationName = "RegisterTaskFinishedNotificationName"
let CreateBetTaskFinishedNotificationName = "CreateBetTaskFinishedNotificationName"
let GetBetsTaskFinishedNotificationName = "GetBetsTaskFinishedNotificationName"
let GetCommentBetsTaskFinishedNotificationName = "GetCommentBetsTaskFinishedNotificationName"
let GetMyBetsTaskFinishedNotificationName = "GetMyBetsTaskFinishedNotificationName"
func secondOffsetFromGMT() -> Int { return NSTimeZone.systemTimeZone().secondsFromGMT }
public class Reachability {
    class func checkConnectedToNetwork() {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        } else {
            println("Internet connection FAILED")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
    }
    class func isConnectedToNetwork()->Bool{
    
        var Status:Bool = false
        let url = NSURL(string: "http://google.com/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
    
        var response: NSURLResponse?
    
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
    
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
    
        return Status
    }
}
enum Status: String {
    case Ok = "OK"
    case Error = "ERROR"
}

extension NSDate {
    class func getDateFromJSON(dateString:NSString) -> NSDate{
        
        
        var dateFormatter = NSDateFormatter()
        
        if(dateString.length == 19)
        {
            dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss" //This is the format returned by .Net website
        }
        else if(dateString.length == 21)
        {
            dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.S" //This is the format returned by .Net website
        }
        else if(dateString.length == 22)
        {
            dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SS" //This is the format returned by .Net website
        }
        else if(dateString.length == 23)
        {
            dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS"
        }
        
        var date = dateFormatter.dateFromString(dateString as String)
        
        
        return date!;
        
    }
}

