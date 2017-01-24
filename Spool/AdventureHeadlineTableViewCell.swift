//
//  AdventureHeadlineTableViewCell.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/11/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class AdventureHeadlineTableViewCell: UITableViewCell {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    var adventureId: Int?
    var creator: User?{
        didSet{
            showEditButton()
        }
    }
    
    @IBAction func editAdventure(_ sender: UIButton) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func showEditButton() {
        if let currentUser = appDelegate.authentication.currentUser, let adventureCreator = creator {
            editButton.isHidden = currentUser.id != adventureCreator.id
        } else {
            editButton.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
