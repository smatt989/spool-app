//
//  AdventureShareViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/30/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class AdventureShareViewController: UIFormViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var adventureId: Int? {
        didSet {
            if adventureId != nil {
                Adventure.fetchAdventure(id: adventureId!){ [weak weakself = self] in
                    weakself?.adventure = $0
                }
            }
        }
    }
    
    var adventure: Adventure? {
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.setupUI()
            }
        }
    }
    var creator: User?
    
    private var editable: Bool {
        get {
            if let cr = creator, let us = appDelegate.authentication.currentUser, cr.id == us.id {
                return true
            } else {
                return false
            }
        }
    }
    
    var searching = false
    
    var additionalDismissalActions: (() -> Void)?
    
    private func setupUI() {
        if AdventureUtilities.validTitle(title: adventure?.name) {
            adventureTitleInput.text = adventure?.name
        } else {
            adventureTitleInput.text = AdventureNameGenerator().generateRandomAdventureName()
        }
        adventureDescriptionInput.text = adventure?.info
        if !editable {
            adventureTitleInput.isUserInteractionEnabled = false
            adventureDescriptionInput.isUserInteractionEnabled = false
        }
    }
    
    private var toShareWith = [User]()
    

    private var addedUsers = [User]() {
        didSet {
            redrawTable()
        }
    }
    
    private var searchedUsers = [User](){
        didSet {
            //hack to get people you know on the top
            var ordered = [User]()
            var knownUsersIndex = 0
            searchedUsers.forEach{ user in
                if addedUsers.contains(where: { $0.id == user.id}) {
                    ordered.insert(user, at: knownUsersIndex)
                    knownUsersIndex += 1
                } else {
                    ordered.append(user)
                }
            }
            searchedUsers = ordered
            redrawTable()
        }
    }
    
    private func addUserToShare(_ user: User) {
        toShareWith.append(user)
    }
    
    private func removeUserToShare(_ user: User) {
        toShareWith = toShareWith.filter{ $0.id != user.id }
    }
    
    private func shareWithUsers() {
        let shareRequests = toShareWith.map{user in AdventureShareRequest(adventureId: adventure!.id!, shareWithUserId: user.id, note: nil)}
        
        AdventureShareRequest.shareMany(shareRequests, success: {
            
        }, failure: { _ in
            print("DID NOT SHARE")
        })
    }
    
    private func loadAddedUsers() {
        User.addedUsers(success: { [weak weakself = self] in
            weakself?.addedUsers = $0
            }, failure: {
                print($0)
        }
        )
    }
    
    private var searchBarListener: NSObjectProtocol?
    
    private func listenToSearch() {
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        
        searchBarListener = center.addObserver(
            forName: Notification.Name.UITextFieldTextDidChange,
            object: searchBoxInput,
            queue: queue) { [weak weakself = self] notification in
                if let query = weakself?.searchBoxInput.text, query.characters.count > 2 {
                    weakself?.searching = true
                    User.search(query: query, success: {
                        weakself?.searchedUsers = $0
                    }, failure: { _ in
                        print("DIDN'T GET SEARCH")
                    })
                } else {
                    weakself?.searching = false
                    weakself?.redrawTable()
                }
        }
    }
    
    private func stopListeningToSearch() {
        if let observer = searchBarListener {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func redrawTable() {
        DispatchQueue.main.async { [weak weakself = self] in
            weakself?.tableView.reloadData()
            weakself?.tableView.setNeedsDisplay()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Identifiers.shareWithUserCell, for: indexPath) as! UserShareTableViewCell

        if searching {
            cell.user = searchedUsers[indexPath.row]
        } else {
            cell.user = addedUsers[indexPath.row]
        }
        
        cell.added = addedUsers.contains{
            $0.id == cell.user!.id
        }
        
        cell.setup()
        //cell.isHidden = isHiddenCell(username: cell.user!.username)
        cell.addShareCallback = addUserToShare
        cell.removeShareCallback = removeUserToShare
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searching {
            return searchedUsers.count
        } else {
            return addedUsers.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonAction(_ sender: UIButton) {
        if editable {
            if AdventureUtilities.validTitle(title: adventureTitleInput.text) {
                adventure?.name = adventureTitleInput.text!
                adventure?.info = adventureDescriptionInput.text
                print("SAVING WITH ID: \(adventure!.id)")
                Adventure.postAdventure(adv: adventure!) { [weak weakself = self] in
                    weakself?.adventure = $0
                    weakself?.shareWithUsers()
                }
            }
        } else {
            shareWithUsers()
        }
        additionalDismissalActions?()
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var adventureTitleInput: UITextField!
    @IBOutlet weak var adventureDescriptionInput: UITextView!
    
    @IBOutlet weak var searchBoxInput: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        setupAdventureTitle()
        setupAdventureDecription()
        setupSearchBox()
        
        // Style table
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    private func styleSearchbox() {
        self.searchBoxInput.layer.cornerRadius = 0
    }
    
    private func setupAdventureTitle() {
        adventureTitleInput.delegate = self
        adventureTitleInput.returnKeyType = .done
    }
    
    private func setupAdventureDecription() {
        adventureDescriptionInput.delegate = self
        adventureDescriptionInput.returnKeyType = .done
    }
    
    private func setupSearchBox() {
        searchBoxInput.delegate = self
        searchBoxInput.autocorrectionType = UITextAutocorrectionType.no
        searchBoxInput.returnKeyType = .done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAddedUsers()
        listenToSearch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopListeningToSearch()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
