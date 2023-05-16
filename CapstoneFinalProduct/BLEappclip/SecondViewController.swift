//
//  SecondViewController.swift
//  BLEappclip
//
//  Created by Jason Fornek on 4/18/23.
//

import UIKit
import Foundation
import CoreBluetooth

class SecondViewController: UIViewController, CBPeripheralDelegate {
    
    var sourceVC: ViewController = ViewController()
    var sourceVC2: TableViewController = TableViewController()
    
    @IBOutlet weak var connectedToLbl2: UILabel!
    @IBOutlet weak var connectionSymbol2: UIImageView!
    
    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        connectedToLbl2.text = "Connected to \((SingletonClass.shared.curPeripheral?.name!)!)"
        connectedToLbl2.textColor = UIColor.blue
        connectionSymbol2.image = UIImage(named: "checkmarkflat") // displays a green checkmark on the device
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.title = "Manage Entry Codes"
    }
    
    @IBAction func manageCodesButton() {
        print("the manage codes button was pressed")
        self.sourceVC.write(data: "U")
        self.sourceVC2.tableView.reloadData()
    }
}

