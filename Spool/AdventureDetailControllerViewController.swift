//
//  AdventureDetailControllerViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/28/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation

class AdventureDetailControllerViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    var adventureId: Int?
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var editButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if adventureHeadline == nil {
            resetAll()
        }
        if adventureId != nil {
            setupLocationFinder()
        }
        
        showEditButton()
        
        // Transparent Navigation
        TransparentUINavigationController().navBarTransparent(controller: self.navigationController!)
    }
    
    private func setupLocationFinder() {
        locationFinder = LocationFinder(callback: getAdventureDetailAndUpdateClassAdventureHeadline)
        locationFinder!.findLocation()
    }
    
    private var locationFinder: LocationFinder?
    
    private func getAdventureDetailAndUpdateClassAdventureHeadline(location: CLLocation) {
        AdventureHeadlineDetail.fetchOneAdventure(adventureId: adventureId!, location: location.coordinate){ [weak weakself = self] in
            weakself?.adventureHeadline = $0
        }
    }

    var adventureHeadline: AdventureHeadlineDetail? {
        didSet {
            if adventureHeadline != nil {
                updateUI(adventure: adventureHeadline!)
            }
        }
    }
    
    private func updateUI(adventure: AdventureHeadlineDetail) {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.resetAll()
            weakself?.updateTitleLabel(adventure: adventure)
            weakself?.updateDescriptionLabel(adventure: adventure)
            weakself?.updateCreatedByLabel(adventure: adventure)
            weakself?.updateSharedByLabel(adventure: adventure)
            weakself?.updateDistanceAway(adventure: adventure)
            weakself?.updateProgress(adventure: adventure)
        }
    }
    
    private func resetAll() {
        titleLabel.isHidden = true
        descriptionLabel.isHidden = true
        createdByLabel.isHidden = true
        createdByLabelPrepend.isHidden = true
        sharedByLabel.isHidden = true
        sharedByLabelPrepend.isHidden = true
        sharedByStack.isHidden = true
        distanceAwayLabel.isHidden = true
        progressLabel.isHidden = true
        startAdventureButton.isHidden = true
        restartButtonsStack.isHidden = true
    }
    
    private func updateTitleLabel(adventure: AdventureHeadlineDetail) {
        titleLabel.text = adventure.title
        titleLabel.isHidden = false
    }
    
    private func updateDescriptionLabel(adventure: AdventureHeadlineDetail) {
        descriptionLabel.text = adventure.subtitle
        descriptionLabel.isHidden = false
    }
    
    private func updateCreatedByLabel(adventure: AdventureHeadlineDetail) {
        createdByLabel.text = adventure.creator.username
        
        createdByLabel.isHidden = false
        createdByLabelPrepend.isHidden = false
    }
    
    private func updateSharedByLabel(adventure: AdventureHeadlineDetail) {
        if adventure.sharers.count > 0 {
            sharedByLabel.text = (adventure.sharers.map{$0.username}).joined(separator: ", ")
            
            sharedByStack.isHidden = false
            sharedByLabel.isHidden = false
            sharedByLabelPrepend.isHidden = false
        } else {
            sharedByStack.isHidden = true
            sharedByLabel.isHidden = true
            sharedByLabelPrepend.isHidden = true
        }
    }
    
    private func updateDistanceAway(adventure: AdventureHeadlineDetail) {
        distanceAwayLabel.text = AdventureUtilities.distanceToString(distance: adventure.distance)
        
        distanceAwayLabel.isHidden = false
    }
    
    private func showEditButton() {
        if let currentUser = appDelegate.authentication.currentUser, let adventureCreator = adventureHeadline?.creator {
            editButton.isHidden = currentUser.id != adventureCreator.id
        } else {
            editButton.isHidden = true
        }
    }
    
    private func updateProgress(adventure: AdventureHeadlineDetail) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if adventure.finished {
            progressLabel.text = "You finished this adventure on \(dateFormatter.string(from: adventure.lastUpdate! as Date))"
                startAdventureButton.setTitle("Restart", for: .normal)
            
            startAdventureButton.isHidden = false
            restartButtonsStack.isHidden = true
            progressLabel.isHidden = false
        } else if adventure.started {
            print("STARTED")
            progressLabel.text = "You already started this adventure"
            
            restartButtonsStack.isHidden = false
            startAdventureButton.isHidden = true
            progressLabel.isHidden = false
        } else {
            startAdventureButton.isHidden = false
            restartButtonsStack.isHidden = true
            progressLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var sharedByLabel: UILabel!
    @IBOutlet weak var distanceAwayLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var sharedByStack: UIStackView!
    
    @IBOutlet weak var createdByLabelPrepend: UILabel!
    @IBOutlet weak var sharedByLabelPrepend: UILabel!
    
    @IBOutlet weak var continueAdventureButton: UIButton!
    @IBOutlet weak var startAdventureButton: UIButton!
    @IBOutlet weak var restartButtonsStack: UIStackView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.startAdventureSegue {
            if let viewController = segue.destination as? EnterAdventureViewController {
                viewController.adventureId = adventureId!
            }
        } else if segue.identifier == Identifiers.continueAdventureSeguge {
            if let viewController = segue.destination as? EnterAdventureViewController {
                viewController.adventureId = adventureId!
                viewController.continueAdventure = true
            }
        } else if segue.identifier == Identifiers.adventureScreenShareAdventure {
            if let viewController = segue.destination as? AdventureShareViewController {
                viewController.adventureId = adventureId
                viewController.creator = adventureHeadline?.creator
            }
        } else if segue.identifier == Identifiers.editAdventureSegue {
            if let viewController = segue.destination as? AdventureEditingViewController {
                viewController.adventureId = adventureId
            }
        }
    }
    
}
