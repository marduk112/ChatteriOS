//
//  CommentDetailsViewController.swift
//  Email
//
//  Created by Szymon Wójcik on 24/05/15.
//  Copyright (c) 2015 Szymon Wójcik. All rights reserved.
//

import Foundation
import UIKit
class CommentDetailsViewController : UIViewController {
    var comment: BetComment?
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let comment = comment {
            userLabel.text = "username \(comment.UserName)"
            commentLabel.text = "comment \(comment.Comment)"
            dateCreatedLabel.text = "date created \(comment.DateCreated)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}