//
//  Bet.swift
//  Email
//
//  Created by Szymon Wójcik on 01/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation

class ApplicationUser {
    var Email = ""
    var Point = 0
    var Id = ""
    var UserName = ""
}

class Bet {
    var Id = 0
    var Title = ""
    var DateCreated = NSDate()
    var EndDate = NSDate()
    var Description = ""
    var RequiredPoints = 0
    var Result = false
    let User = ApplicationUser()
}

