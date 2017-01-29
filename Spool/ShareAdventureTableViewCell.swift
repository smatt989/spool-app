//
//  ShareAdventureTableViewCell.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/28/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ShareAdventureTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionImage: UIImageView!
    
    var user: User?
    var added = false
    var toBeShared = false
    
    var addShareCallback: ((User) -> Void)?
    var removeShareCallback: ((User) -> Void)?
    
    func setup() {
        actionImage.isHidden = false
        if let u = user {
            usernameLabel.text = u.username
        }
        if toBeShared {
            actionImage.image = check
        }
        if !added {
            actionImage.image = plus
        }
        if added && !toBeShared {
            actionImage.isHidden = true
        }
    }
    
    private let check = #imageLiteral(resourceName: "check")
    private let plus = #imageLiteral(resourceName: "plus")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionImage.isHidden = true
    }
    
    private func addUserConnection() {
        let connectionRequest = UserConnectionAddRequest(addUserId: user!.id)
        User.addUser(addUserRequest: connectionRequest, success: { [weak weakself = self] _ in
            weakself?.added = true
        }, failure: { _ in
            print("failed to add")
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if added {
            toBeShared = !toBeShared
            if toBeShared {
                addShareCallback?(user!)
            } else {
                removeShareCallback?(user!)
            }
        } else if !added {
            addUserConnection()
        }
        setup()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
