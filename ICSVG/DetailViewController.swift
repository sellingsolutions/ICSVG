//
//  DetailViewController.swift
//  ICSVG
//
//  Created by Alexander Selling on 2018-12-22.
//  Copyright © 2018 Alexander Selling. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var space: [String: Any]?
    var keyNames = ["AltExternalId", "RoomTag"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let space = space, space.count >= keyNames.count else {
            return 0
        }
        return keyNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let key = keyNames[indexPath.row]
        
        let value = space?[key]
        
        var keyLabel = key
        if key == "AltExternalId" {
            keyLabel = "id"
        }
        if key == "RoomTag" {
            keyLabel = "Space"
        }
        
        cell.textLabel?.text = keyLabel
        cell.detailTextLabel?.text = "\(value ?? "")"
        
        return cell
    }
}
