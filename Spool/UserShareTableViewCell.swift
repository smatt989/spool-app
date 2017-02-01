//
//  UserShareTableViewCell.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/30/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class UserShareTableViewCell: UITableViewCell {

    var user: User?
    var added = false
    var toBeShared = false
    
    
    private let checked = #imageLiteral(resourceName: "Checkbox full")
    private let unchecked = #imageLiteral(resourceName: "Checkbox empty")
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionImage: UIImageView!

    @IBOutlet weak var addConnectionButton: UIButton!
    
    @IBAction func addConnection(_ sender: UIButton) {
        addUserConnection()
    }
    
    var addShareCallback: ((User) -> Void)?
    var removeShareCallback: ((User) -> Void)?
    
    func setup() {
        DispatchQueue.main.async { [weak weakself = self] in
        weakself?.actionImage.isHidden = true
        weakself?.addConnectionButton.isHidden = true
        if let u = weakself?.user {
            weakself?.usernameLabel.text = u.username
        }
        if weakself!.toBeShared {
            weakself?.actionImage.image = weakself?.checked
        } else {
            weakself?.actionImage.image = weakself?.unchecked
        }
        if !weakself!.added {
            weakself?.addConnectionButton.isHidden = false
        } else {
            weakself?.addConnectionButton.isHidden = true
            weakself?.actionImage.isHidden = false
        }
        }
    }
    
    private func addUserConnection() {
        let connectionRequest = UserConnectionAddRequest(addUserId: user!.id)
        User.addUser(addUserRequest: connectionRequest, success: { [weak weakself = self] _ in
            weakself?.added = true
            print("added")
            weakself?.setup()
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
        }
        setup()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
