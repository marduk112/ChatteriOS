//
//  BetParticipant.swift
//  Email
//
//  Created by Szymon Wójcik on 21/06/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import RealmSwift
class BetParticipant: Object {
    dynamic var Id = 0
    dynamic var UserName = ""
    dynamic var Option = false
    
    override static func primaryKey() -> String? {
        return "Id"
    }
}