//
//  BetComment.swift
//  Email
//
//  Created by Szymon Wójcik on 24/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import RealmSwift
class BetComment: Object {
    dynamic var Id = 0
    dynamic var Comment = ""
    dynamic var DateCreated = NSDate()
    dynamic var BetId = 0
    dynamic var UserName = ""
    
    override static func primaryKey() -> String? {
        return "Id"
    }
}