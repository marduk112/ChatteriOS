//
//  AuthenticationAndRegistration.swift
//  Email
//
//  Created by Szymon Wójcik on 18/04/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import Alamofire

class AuthenticationAndRegistration{    
    
    func registration(email: String, password: String, confirmPassword: String){
        var parameters = ["Email" : email, "Password" : password, "ConfirmPassword" : confirmPassword] as Dictionary<String, String>
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/api/Account/Register")
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            if(error != nil) {
                println(error.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(RegisterTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : error.localizedDescription])
                })
            }
            else {
                if let result = response as? NSHTTPURLResponse {
                    if result.statusCode == 200 {
                        dispatch_async(dispatch_get_main_queue(), {
                            NSNotificationCenter.defaultCenter().postNotificationName(RegisterTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                        })
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), {
                            NSNotificationCenter.defaultCenter().postNotificationName(RegisterTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : "Bad request"])
                        })
                    }
                }
            }
        })
        task.resume()
    }
    func authentication(email: String, password: String){
        let parameters = "grant_type=password&username=" + email + "&password=" + password
        let postData = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: restServiceUrl + "/Token")
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        var err: NSError?
        request.HTTPBody = postData
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(AuthTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : err!.localizedDescription])
                })
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                println(json)
                if let parseJSON = json {                
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            authData.accessToken = parseJSON["access_token"] as! String
                            authData.expiresIn = parseJSON["expires_in"] as! Int
                            authData.tokenType = parseJSON["token_type"] as! String
                            dispatch_async(dispatch_get_main_queue(), {
                                NSNotificationCenter.defaultCenter().postNotificationName(AuthTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Ok.rawValue])
                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                NSNotificationCenter.defaultCenter().postNotificationName(AuthTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : parseJSON["error_description"] as! String])
                            })
                        }
                    }
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    dispatch_async(dispatch_get_main_queue(), {
                        NSNotificationCenter.defaultCenter().postNotificationName(AuthTaskFinishedNotificationName, object: nil, userInfo: ["status" : Status.Error.rawValue, "error" : "Problem with server"])
                    })
                }
            }
        })
        
        task.resume()       
    }
}
