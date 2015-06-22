//
//  Bet.swift
//  Email
//
//  Created by Szymon Wójcik on 01/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import RealmSwift

class ApplicationUser {
    dynamic var Email = ""
    dynamic var Point = 0
    dynamic var Id = ""
    dynamic var UserName = ""
}

class Bet: Object {
    dynamic var Id = 0
    dynamic var Title = ""
    dynamic var DateCreated = NSDate()
    dynamic var EndDate = NSDate()
    dynamic var Description = ""
    dynamic var RequiredPoints = 0
    dynamic var Result = false
    let User = ApplicationUser()
    
    override static func primaryKey() -> String? {
        return "Id"
    }
}

