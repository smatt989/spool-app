//
//  ShareAdventureTableViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/28/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class ShareAdventureTableViewController: UITableViewController, UISearchDisplayDelegate, UISearchBarDelegate {

    var adventureId: Int?
    
    private var addedUsers = [User](){
        didSet {
            redrawTable()
        }
    }
    
    private var awaitingUsers = [User](){
        didSet {
            redrawTable()
        }
    }
    
    private var searchedUsers = [User](){
        didSet {
            redrawTable()
        }
    }
    
    @IBAction func submitShare(_ sender: UIBarButtonItem) {
        shareWithUsers()
    }
    
    private func redrawTable() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.tableView.reloadData()
            weakself?.tableView.setNeedsDisplay()
        }
    }
    
    private var toShareWith = [User]()
    
    private func addUserToShare(_ user: User) {
        toShareWith.append(user)
    }
    
    private func shareWithUsers() {
        let shareRequests = toShareWith.map{user in AdventureShareRequest(adventureId: adventureId!, shareWithUserId: user.id, note: nil)}
        
        AdventureShareRequest.shareMany(shareRequests, success: {
            
        }, failure: { _ in
            print("DID NOT SHARE")
        })
    }
    
    private var toFilterOn: String? {
        didSet {
            redrawTable()
        }
    }
    
    private func updateFilter(query: String) {
        toFilterOn = query
    }
    
    private func removeUserToShare(_ user: User) {
        toShareWith = toShareWith.filter{ $0.id != user.id }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTable()
    }
    
    private func loadTable() {
        loadAddedUsers()
        loadAwaitingUsers()
    }
    
    private func loadAddedUsers() {
        print("loading")
        User.addedUsers(success: { [weak weakself = self] in
                print("in here")
                weakself?.addedUsers = $0
            }, failure: {
                print($0)
            }
        )
    }
    
    private func loadAwaitingUsers() {
        User.awaitingUsers(success: { [weak weakself = self] in
            weakself?.awaitingUsers = $0
            }, failure: {
                print($0)
            }
        )
    }
    
    private func loadSearchedUsers() {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            toFilterOn = searchText
        } else {
            toFilterOn = nil
        }
        if searchText.characters.count > 2 {
            User.search(query: searchText, success: { [weak weakself = self] in
                print("THIS MANY: \($0.count)")
                weakself?.searchedUsers = $0
                //redrawTable()
            }, failure: { _ in
                print("PROBLEM SEARCHING")
            })
        } else {
            searchedUsers = [User]()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Identifiers.shareAdventureCell, for: indexPath) as! ShareAdventureTableViewCell
        if indexPath.section == 0 {
            cell.user = addedUsers[indexPath.row]
            cell.added = true
        } else if indexPath.section == 1 {
            cell.user = awaitingUsers[indexPath.row]
            cell.added = false
        } else if indexPath.section == 2 {
            cell.user = searchedUsers[indexPath.row]
            cell.added = false
        }
        cell.setup()
        cell.isHidden = isHiddenCell(username: cell.user!.username)
        cell.addShareCallback = addUserToShare
        cell.removeShareCallback = removeUserToShare
        return cell
    }
    
    private func isHiddenCell(username: String) -> Bool {
        if let filterString = toFilterOn {
            if username.lowercased().range(of: filterString.lowercased()) != nil {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Added Users"
        } else if section == 1 {
            return "Already Added You"
        } else if section == 2{
            return "Other Users"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return addedUsers.filter{!isHiddenCell(username: $0.username)}.count
        } else if section == 1 {
            return awaitingUsers.filter{!isHiddenCell(username: $0.username)}.count
        } else if section == 2 {
            return searchedUsers.count
        }
        return 0
    }

}
