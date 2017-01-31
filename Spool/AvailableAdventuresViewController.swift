//
//  AvailableAdventuresViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/29/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit
import CoreLocation

class AvailableAdventuresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    var adventures: [AdventureHeadlineDetail] = [AdventureHeadlineDetail]()
        {
        didSet {
            newReceivedAdventures = [AdventureHeadlineDetail]()
            previouslyStartedAdventures = [AdventureHeadlineDetail]()
            nearbyAdventures = [AdventureHeadlineDetail]()
            yourAdventures = [AdventureHeadlineDetail]()
            otherAdventures = [AdventureHeadlineDetail]()
            
            
            adventures.forEach{ adventure in
                switch adventure {
                case let a where a.sharers.count > 0 && !a.started:
                    newReceivedAdventures.append(a)
                case let a where a.started:
                    previouslyStartedAdventures.append(a)
                case let a where a.distance <= 5000:
                    nearbyAdventures.append(a)
                case let a where a.creator.id == appDelegate.authentication.currentUser?.id:
                    yourAdventures.append(a)
                default:
                    otherAdventures.append(adventure)
                }
            }
            
            
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.tableView.reloadData()
                weakself?.tableView.setNeedsDisplay()
            }
        }
    }
    
    private var newReceivedAdventures = [AdventureHeadlineDetail]()
    private var previouslyStartedAdventures = [AdventureHeadlineDetail]()
    private var nearbyAdventures = [AdventureHeadlineDetail]()
    private var yourAdventures = [AdventureHeadlineDetail]()
    private var otherAdventures = [AdventureHeadlineDetail]()
    
    private func newReceivedAdventuresa() -> [AdventureHeadlineDetail] {
        return adventures.filter{$0.sharers.count > 0 && !$0.started}
    }
    
    private func previouslyStartedAdventuresa() -> [AdventureHeadlineDetail] {
        return adventures.filter{$0.started}
    }
    
    private func nearbyAdventuresa() -> [AdventureHeadlineDetail] {
        return adventures.filter{$0.sharers.count == 0 && $0.distance < 5000}
    }
    
    private func otherAdventuresa() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //SEEMS LIKE A BAD WAY TO SIZE THESE...
        tableView.rowHeight = 100.0
        tableView.estimatedRowHeight = 100.0
        // Style table
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }

    private var locationFinder: LocationFinder?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style Navbar
        TransparentUINavigationController().navBarDefault(controller: self.navigationController!)
    }
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lookupArrayBySection(section).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let lookupArrayCount = lookupArrayBySection(section).count
        if lookupArrayCount > 0 {
            switch section {
            case 0: return "New Adventures"
            case 1: return "Continue Adventures"
            case 2: return "Nearby Adventures"
            case 3: return "Adventures You Created"
            case 4: return "Other Adventures"
            default: return ""
            }
        } else {
            return nil
        }
    }
    
    private func lookupArrayBySection(_ int: Int) -> [AdventureHeadlineDetail] {
        switch int {
        case 0: return newReceivedAdventures
        case 1: return previouslyStartedAdventures
        case 2: return nearbyAdventures
        case 3: return yourAdventures
        default: return otherAdventures
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.adventureHeadlineCell, for: indexPath) as! AdventureHeadlineTableViewCell
        
        let lookupArray = lookupArrayBySection(indexPath.section)
        
        cell.adventureHeadlineDetail = lookupArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.showMapSegue {
            if let viewController = segue.destination as? AdventureEditingViewController, let button = sender as? UIButton {
                viewController.adventureId = (button.superview!.superview! as! AdventureHeadlineTableViewCell).adventureHeadlineDetail?.id
            }
        } else if segue.identifier == Identifiers.newAdventureSegue {
            if let viewController = segue.destination as? AdventureEditingViewController {
                viewController.adventureId = nil
            }
        } else if segue.identifier == Identifiers.adventureDetailSegue {
            if let viewController = segue.destination as? AdventureDetailControllerViewController, let cell = sender as? AdventureHeadlineTableViewCell {
                viewController.adventureId = cell.adventureHeadlineDetail?.id
                viewController.adventureHeadline = cell.adventureHeadlineDetail
                //viewController.adventureHeadline = cell.adv
            }
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        User.logout{ [weak weakself = self] in
            weakself?.appDelegate.routeGivenAuthentication()
        }
    }
}
