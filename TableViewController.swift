//
//  TableViewController.swift
//  TestClip1
//
//  Created by Jason Fornek on 2/27/23.
//

import UIKit

class TableViewController: UITableViewController {
    
    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    public var models: [String] = ["Entry code 1: (code here)", "Entry code 2: (code here)", "Entry code 3: (code here)"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.textLabel?.textColor = UIColor.blue
        return cell
    }

}
