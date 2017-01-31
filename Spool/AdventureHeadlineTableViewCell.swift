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
    @IBOutlet var creatorLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet weak var sharedByLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    var adventureHeadlineDetail: AdventureHeadlineDetail? {
        didSet {
            setup()
        }
    }
    
    private func setup() {
        if let adv = adventureHeadlineDetail {
            titleLabel.text = adv.title
            descriptionLabel.text = adv.subtitle
            distanceLabel.text = AdventureUtilities.distanceToString(distance: adv.distance)
            creatorLabel.text = adv.creator.username
            setupProgress()
            setupSharedBy()
            showEditButton()
        }
    }
    
    private func setupProgress() {
        if adventureHeadlineDetail?.finished == true {
            progressLabel.text = "finished"
        } else if adventureHeadlineDetail?.started == true {
            progressLabel.text = "started"
        } else {
            progressLabel.isHidden = true
        }
    }
    
    private func setupSharedBy() {
        if let users = adventureHeadlineDetail?.sharers, users.count > 0 {
            sharedByLabel.text = (users.map{$0.username}).joined(separator: ", ")
        } else {
            sharedByLabel.isHidden = true
            toLabel.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private func showEditButton() {
        if let currentUser = appDelegate.authentication.currentUser, let adventureCreator = adventureHeadlineDetail?.creator {
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
