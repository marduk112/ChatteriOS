//
//  BetsRESTServices.swift
//  Email
//
//  Created by Szymon Wójcik on 21/06/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class BetsRESTServices {
    class func getParticipantsRestService() {
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/BetParticipants")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
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
                    NSNotificationCenter.defaultCenter().postNotificationName(GetParticipantsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &err) as! NSArray
                for bet in json {
                    let temp = bet as! NSDictionary
                    let b = BetParticipant()
                    if let data: AnyObject? = temp["Id"] {
                        b.Id = data as! Int
                        if betParticipantsList.filter({ el in el.Id == (data as! Int)}).count > 0 {
                            break
                        }
                    }
                    if let data: AnyObject? = temp["BetId"] {
                        if currentlyConsiderationBet?.Id != (data as! Int) {
                            break
                        }
                    }
                    if let data: AnyObject? = temp["UserName"] {
                        b.UserName = data as! String
                    }
                    if let data: AnyObject? = temp["Option"] {
                        b.Option = data as? Bool
                    }
                    betParticipantsList.append(b)                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(GetParticipantsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                })
            }
        })
        task.resume()
    }
    
    class func logoutRestService() {
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/Account/Logout")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(LogoutTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(LogoutTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : "Error with logout"])
                    })
                }
            }
        })
        task.resume()
    }
    
    class func addComment(newComment: BetComment) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let parameters = ["Commment" : newComment.Comment, "DateCreated" : dateFormatter.stringFromDate(newComment.DateCreated),
            "BetId" : String(newComment.BetId)]
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/BetComments")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
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
                    NSNotificationCenter.defaultCenter().postNotificationName(AddCommentBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                newComment.DateCreated = NSDate()
                commentList.append(newComment)
                commentList.sort({ $0.DateCreated.compare($1.DateCreated) == NSComparisonResult.OrderedDescending })
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(AddCommentBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])                    
                })
            }
        })
        task.resume()
    }
    
    class func getComments() {
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/BetComments")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
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
                    NSNotificationCenter.defaultCenter().postNotificationName(GetCommentBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &err) as! NSArray
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                calendar?.timeZone = NSTimeZone.systemTimeZone()
                let components = NSDateComponents()
                components.calendar = calendar
                components.second = secondOffsetFromGMT()
                for bet in json {                    
                    let temp = bet as! NSDictionary
                    let b = BetComment()
                    if let data:AnyObject? = temp["BetId"]{
                        b.BetId = data as! Int
                        if let t = currentlyConsiderationBet?.Id {
                            if t != (data as! Int) {
                                break
                            }
                        }
                    }
                    if let data:AnyObject? = temp["Id"]{
                        b.Id = data as! Int
                        if commentList.filter({ el in el.Id == (data as! Int)}).count > 0 {
                            break
                        }
                    }
                    if let data:AnyObject? = temp["Commment"]{
                        b.Comment = data as! String
                    }
                    if let data:AnyObject? = temp["DateCreated"]{
                        let date = data as! String
                        b.DateCreated = NSDate.getDateFromJSON(date)
                        b.DateCreated = calendar!.dateByAddingComponents(components, toDate: b.DateCreated, options: nil)!
                    }
                    if let data:AnyObject? = temp["UserName"]{
                        b.UserName = data as! String
                    }
                    commentList.append(b)
                    
                }
                commentList.sort({ $0.DateCreated.compare($1.DateCreated) == NSComparisonResult.OrderedDescending })
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(GetCommentBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                })
            }
        })
        task.resume()
    }
    
    class func createBetRestService(parameters: [String: String!], inout betId: Int) {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/Bets")
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
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
                let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &err) as! NSDictionary
                betId = (json["Id"] as? Int)!                
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(CreateBetTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                })
            }
        })
        task.resume()
    }
    
    class func getBetsRestService() {
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/Bets")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
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
                let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                calendar?.timeZone = NSTimeZone.systemTimeZone()
                let components = NSDateComponents()
                components.calendar = calendar
                components.second = secondOffsetFromGMT()
                for bet in json {
                    let temp = bet as! NSDictionary
                    let b = Bet()
                    if let data: AnyObject? = temp["Id"] {
                        b.Id = data as! Int
                        if betList.filter({ el in el.Id == (data as! Int)}).count > 0 {
                            break
                        }
                    }
                    if let data: AnyObject? = temp["Title"] {
                        b.Title = data as! String
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
                }
                betList.sort({ $0.DateCreated.compare($1.DateCreated) == NSComparisonResult.OrderedDescending })
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(GetBetsTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                })
            }
        })
        task.resume()
    }
    
    class func getUserInfoRestService(){
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/Account/UserPoints")
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        var err: NSError?
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer " + KeychainWrapper.stringForKey("Token")!, forHTTPHeaderField: "Authorization")
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &err) as! NSDictionary
                    authData.points = json["Points"] as! Int
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(GetUserPointsTaskStartNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                    })
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(GetUserPointsTaskStartNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : "Error with getting points"])
                    })
                }
            }
        })
        task.resume()
    }

}