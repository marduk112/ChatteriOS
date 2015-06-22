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
    var points = 0
}


let EMAIL_PATTERN = "[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@" + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})";
let PASSWORD_PATTERN = "(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{6,}";


var currentlyConsiderationBet: Bet?
let authData = AuthenticationData()
let restServiceUrl = "http://chatterrest.apphb.com"
let AuthTaskFinishedNotificationName = "AuthTaskFinishedNotificationName"
let RegisterTaskFinishedNotificationName = "RegisterTaskFinishedNotificationName"
let CreateBetTaskFinishedNotificationName = "CreateBetTaskFinishedNotificationName"
let GetBetsTaskFinishedNotificationName = "GetBetsTaskFinishedNotificationName"
let GetCommentBetsTaskFinishedNotificationName = "GetCommentBetsTaskFinishedNotificationName"
let AddCommentBetsTaskFinishedNotificationName = "AddCommentBetsTaskFinishedNotificationName"
let GetMyBetsTaskFinishedNotificationName = "GetMyBetsTaskFinishedNotificationName"
let GetParticipantsTaskFinishedNotificationName = "GetParticipantsTaskFinishedNotificationName"
let ProceedToBetTaskFinishedNotificationName = "ProceedToBetTaskFinishedNotificationName"
let LogoutTaskFinishedNotificationName = "LogoutTaskFinishedNotificationName"
let LogoutTaskStartNotificationName = "LogoutTaskStartNotificationName"
let GetUserPointsTaskStartNotificationName = "GetUserPointsTaskStartNotificationName"
let GetRewardsTaskStartNotificationName = "GetRewardsTaskStartNotificationName"
let ChooseRewardsTaskStartNotificationName = "ChooseRewardsTaskStartNotificationName"

func secondOffsetFromGMT() -> Int { return NSTimeZone.systemTimeZone().secondsFromGMT }

infix operator =~ {}
func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}
class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
        return matches.count > 0
    }
}

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

