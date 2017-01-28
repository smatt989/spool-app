//
//  AdventuresTableViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation

class AdventuresTableViewController: UITableViewController {
    
    @IBOutlet var adventuresTable: UITableView!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var adventures: [AdventureHeadlineDetail] = [AdventureHeadlineDetail]()
        {
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.tableView.reloadData()
                weakself?.tableView.setNeedsDisplay()
            }
        }
    }
    
    var selectedAdventureId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style Navbar
        TransparentUINavigationController().navBarTransparent(controller: self.navigationController!)
        
        // Style table
        self.adventuresTable.separatorInset = UIEdgeInsets.zero
    }
    
    private var locationFinder: LocationFinder?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTable()
    }
    
    private func loadTable() {
        locationFinder = LocationFinder(callback: fetchAdventuresPlease)
        locationFinder!.findLocation()
    }
    
    private func fetchAdventuresPlease(location: CLLocation) -> Void {
        AdventureHeadlineDetail.fetchAdventures(location: location.coordinate){ [weak weakself = self] advs in
            weakself?.adventures = advs
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adventures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.adventureHeadlineCell, for: indexPath) as! AdventureHeadlineTableViewCell
        let adventure = adventures[indexPath.row]
        var descriptionText = ""
        if adventure.subtitle != nil && adventure.subtitle != "" {
            descriptionText = "\(adventure.subtitle)\nPosted by: \(adventure.creator.username)"
        } else {
            descriptionText = "Posted by: \(adventure.creator.username)"
        }
        
        cell.titleLabel?.text = adventure.title
        cell.descriptionLabel?.text = descriptionText
        cell.adventureId = adventure.id
        cell.creator = adventure.creator
        return cell
    }
 
    private struct Urls {
        static let availableAdventures = URL(string: domain+"/adventures")!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.showMapSegue {
            if let viewController = segue.destination as? AdventureEditingViewController, let button = sender as? UIButton {
                viewController.adventureId = (button.superview!.superview! as! AdventureHeadlineTableViewCell).adventureId
            }
        } else if segue.identifier == Identifiers.newAdventureSegue {
            if let viewController = segue.destination as? AdventureEditingViewController {
                viewController.adventureId = nil
            }
        } else if segue.identifier == Identifiers.enterAdventure {
            if let viewController = segue.destination as? EnterAdventureViewController, let cell = sender as? AdventureHeadlineTableViewCell {
                viewController.adventureId = cell.adventureId
            }
        }
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        User.logout{ [weak weakself = self] in
            weakself?.appDelegate.routeGivenAuthentication()
        }
    }

}
