//
//  AdventuresTableViewController.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/9/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import UIKit

class AdventuresTableViewController: UITableViewController {
    
    var adventures: [AdventureHeadline] = [AdventureHeadline]()
        {
        didSet {
            DispatchQueue.main.async { [weak weakself = self] in
                weakself?.tableView.reloadData()
                weakself?.tableView.setNeedsDisplay()
            }
        }
    }
    
    var selectedAdventureId: Int?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAdventures()
    }
    
    private func fetchAdventures() {
        var request = URLRequest(url: Urls.availableAdventures)
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { [weak weakself = self] data, response, err in
            if let d = data {
                weakself?.adventures = weakself?.parseAdventures(data: d) ?? []
            } else if err != nil {
                print("BIG PROBLEMO")
            }
        }.resume()
    }
    
    private func parseAdventures(data: Data) -> [AdventureHeadline] {
        var newAdventures = [AdventureHeadline]()
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let array = json as? [Any]{
            newAdventures = array.flatMap {element in
                parseOneAdventure(adventureJson: element)
            }
        }
        return newAdventures
    }
    
    private func parseOneAdventure(adventureJson: Any) -> AdventureHeadline? {
        if let dictionary = adventureJson as? [String: Any] {
            if let title = dictionary["name"] as? String, let id = dictionary["id"] as? Int {
                let subtitle = dictionary["description"] as? String ?? ""
                return AdventureHeadline(title: title, subtitle: subtitle, id: id)
            }
        }
        return nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adventures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.adventureHeadlineCell, for: indexPath)
        let adventure = adventures[indexPath.row]
        cell.textLabel?.text = adventure.title
        cell.detailTextLabel?.text = adventure.subtitle

        return cell
    }
 
    private struct Urls {
        static let availableAdventures = URL(string: domain+"/adventures")!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.showMapSegue {
            if let viewController = segue.destination as? AdventureEditingViewController {
                viewController.adventureId = adventures[tableView.indexPathForSelectedRow!.row].id
            }
        } else if segue.identifier == Identifiers.newAdventureSegue {
            if let viewController = segue.destination as? AdventureEditingViewController {
                viewController.adventureId = nil
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow!
//        let adventure = adventures[indexPath.row]
//        
//        selectedAdventureId = adventure.id
//        print("SEGUE")
//        performSegue(withIdentifier: Identifiers.showMapSegue, sender: self)
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
