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

    private var interacted = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIBarButtonItemUppercase!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    var adventures: [AdventureHeadlineDetail] = [AdventureHeadlineDetail]()
        {
        didSet {
            newReceivedAdventures = [AdventureHeadlineDetail]()
            previouslyStartedAdventures = [AdventureHeadlineDetail]()
            nearbyAdventures = [AdventureHeadlineDetail]()
            yourAdventures = [AdventureHeadlineDetail]()
            
            
            adventures.forEach{ adventure in
                switch adventure {
                case let a where a.creator.id == appDelegate.authentication.currentUser?.id:
                    yourAdventures.append(a)
                case let a where a.started && !a.finished && a.distance <= 10000:
                    previouslyStartedAdventures.append(a)
                case let a where a.sharers.count > 0 && !a.started && !a.finished:
                    newReceivedAdventures.append(a)
                case let a where a.distance <= 5000 && !a.finished:
                    nearbyAdventures.append(a)
                default: break
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
    
    private func newReceivedAdventuresa() -> [AdventureHeadlineDetail] {
        return adventures.filter{$0.sharers.count > 0 && !$0.started}
    }
    
    private func previouslyStartedAdventuresa() -> [AdventureHeadlineDetail] {
        return adventures.filter{$0.started}
    }
    
    private func nearbyAdventuresa() -> [AdventureHeadlineDetail] {
        return adventures.filter{$0.sharers.count == 0 && $0.distance < 5000}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //SEEMS LIKE A BAD WAY TO SIZE THESE...
        setupHiddenHeaders()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        // Style table
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }

    private var locationFinder: LocationFinder?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style Navbar
        if let navController = navigationController {
            TransparentUINavigationController().navBarTransparent(controller: navController)
            navController.navigationBar.tintColor = UIColor(red:0.40, green:0.45, blue:0.90, alpha:1.0) //#6772e5
        }
        
        // Style logout button
        logoutButton.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "Nunito-Bold", size: 12)! ,
            NSForegroundColorAttributeName : UIColor(red:0.20, green:0.20, blue:0.36, alpha:1.0) ], for: UIControlState.normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Style Navbar
        loadTable()
    }
    
    private func loadTable() {
        locationFinder = LocationFinder(callback: fetchAdventuresPlease)
        locationFinder!.findLocation()
    }
    
    private func fetchAdventuresPlease(location: CLLocation) -> Void {
        AdventureHeadlineDetail.fetchAdventures(location: location.coordinate){ [weak weakself = self] advs in
            weakself?.adventures = advs
            if !weakself!.interacted {
                weakself?.openMenuOnInit()
            }
        }
    }
    
    private let sectionCount = 4
    private var hidden = [Bool]()
    
    @objc private func tapFunction(sender:UITapGestureRecognizer) {
        let section = sender.view!.tag
        tapSectionFunction(section: section)
    }
    
    private func tapSectionFunction(section: Int) {
        interacted = true
        let indexPaths = (0..<lookupArrayBySection(section).count).map { i in return IndexPath(item: i, section: section)  }
        
        hidden[section] = !hidden[section]
        
        tableView?.beginUpdates()
        
        if hidden[section] {
            tableView?.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView?.insertRows(at: indexPaths, with: .fade)
        }
        
        tableView?.endUpdates()
    }
    
    private func openMenuOnInit() {
        var searching = true
        var section = 0
        
        while searching && section < sectionCount {
            if lookupArrayBySection(section).count > 0 {
                DispatchQueue.main.async{ [weak weakself = self] in
                    weakself?.tapSectionFunction(section: section)
                }
                searching = false
            } else {
                section = section + 1
            }
        }
    }
    
    private func setupHiddenHeaders() {
        (0..<sectionCount).forEach{ _ in
            hidden.append(true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hidden[section] {
            return 0
        } else {
            return lookupArrayBySection(section).count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return drawTableViewHeader(section: section).contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerView = Bundle.main.loadNibNamed("AdventureHeadlineTableViewCell", owner: self, options: nil)?.first as! UIView
        
        if section == 0 && lookupArrayBySection(0).count == 0 {
            return 0.0
        }
        if section == 1 && lookupArrayBySection(1).count == 0 {
            return 0.0
        }
        
        return CGFloat(headerView.bounds.height)
    }
    
    private func lookupArrayBySection(_ int: Int) -> [AdventureHeadlineDetail] {
        switch int {
        case 0: return previouslyStartedAdventures
        case 1: return newReceivedAdventures
        case 2: return nearbyAdventures
        case 3: return yourAdventures
        default: return [AdventureHeadlineDetail]()
        }
    }
    
    private func drawTableViewHeader(section: Int) -> AdventureHeadlineTableViewCell {
        let headerView = Bundle.main.loadNibNamed("AdventureHeadlineTableViewCell", owner: self, options: nil)?.first as! AdventureHeadlineTableViewCell
        var headerTitle: String?
        
        let lookupArrayCount = lookupArrayBySection(section).count
        if lookupArrayCount > 0 {
            switch section {
            case 0:  headerTitle = "Continue Adventures"
            case 1:  headerTitle = "Received Adventures"
            case 2:  headerTitle = "Nearby Adventures"
            case 3:  headerTitle = "Adventures You Created"
            default: break
            }
        }
        
        headerView.headerTitleLabel.text = headerTitle?.uppercased()
        headerView.headerCounter.text = "\(lookupArrayBySection(section).count) Adventures"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        headerView.contentView.isUserInteractionEnabled = true
        headerView.contentView.addGestureRecognizer(tap)
        headerView.contentView.tag = section
        
        // Style custom headers
        if section == sectionCount - 1 {
            headerView.borderBottom.isHidden = !hidden[section]
        } else {
            headerView.borderBottom.isHidden = true
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.adventureHeadlineCell, for: indexPath) as! AdventureHeadlineTableViewCell
        
        let lookupArray = lookupArrayBySection(indexPath.section)
        
        cell.adventureHeadlineDetail = lookupArray[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
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
