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
    
    @IBOutlet weak var borderTop: UIView!
    @IBOutlet weak var borderBottom: UIView!
    @IBOutlet public var headerTitleLabel: UILabel!
    @IBOutlet weak var headerCounter: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet var creatorLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet weak var sharedByLabel: UILabel!
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
        
        // Make label uppercase
        progressLabel.text = progressLabel.text?.uppercased()
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var noBorderBottom: Bool = false {
        didSet {
            self.borderBottom.isHidden = noBorderBottom
        }
    }

}
