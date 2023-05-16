//
//  TableViewController.swift
//  BLEappclip
//
//  Created by Jason Fornek on 4/18/23.
//

import UIKit
import Foundation
import CoreBluetooth

class TableViewController: UITableViewController, CBPeripheralDelegate {

    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }

    var textFields: [UITextField]?
    var sourceVC: ViewController = ViewController()
    var curPeripheral: CBPeripheral?
    var srcharacteristic: CBCharacteristic?
    
    var models: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        models = ["\(SingletonClass.shared.entryCode1!)", "\(SingletonClass.shared.entryCode2!)", "\(SingletonClass.shared.entryCode3!)"]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.title = "Tap on a slot to add or delete a code"
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create an option menu as an action sheet
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Add cancel action to the menu
        let cancelAction  = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add Add-code action
        let addActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Add a code", message: "Enter a 4 digit code", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertMessage.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                guard let fields = alertMessage.textFields, let addCodeField = fields.first,
                      let addedCode = addCodeField.text, addedCode.count == 4 else {
                    print("invalid entry")
                    
                    let alertInvalidEntry = UIAlertController(title: "Invalid Entry", message: "Entry code must be 4 digits long", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertInvalidEntry.addAction(okayAction)
                    self.present(alertInvalidEntry, animated: true, completion: nil)
                    return
                }
                print("The added code is: \(addedCode)")
                let alertSuccess = UIAlertController(title: "Success!", message: "Your code has been added.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertSuccess.addAction(okayAction)
                self.present(alertSuccess, animated: true, completion: nil)
                
                //Call the write function on the source view controller
                if SingletonClass.shared.curPeripheral != nil{
                    print("curPeripheral is not nil")
                    if SingletonClass.shared.srcharacteristic != nil{
                        print("srcharacreristic is not nil")
                        self.sourceVC.write(data: "123455S1")
                        SingletonClass.shared.waitingOn = "B"
                        self.sourceVC.write(data: "\(addedCode)")
                        SingletonClass.shared.waitingOn = "B"
                        self.sourceVC.write(data: "\(addedCode)")
                        SingletonClass.shared.waitingOn = "A"
                    }
                }
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.sourceVC.write(data: "U")
                }
                
                //(when slot 3 clicked on) if slot 1 and 2 are open, then add it to slot 1
                if indexPath.row == 2 && self.models[0] == "empty slot" {
                    self.models[indexPath.row - 2] = "\(addedCode)"
                    self.tableView.reloadData()
                }
                
                //(when slot 3 clicked on) if slot 1 is full and 2 is open, then add it to slot 2
                else if indexPath.row == 2 && self.models[0].count == 4 && self.models[1] == "empty slot" {
                    self.models[indexPath.row - 1] = "\(addedCode)"
                    self.tableView.reloadData()
                }
                
                //(when slot 3 clicked on) if slot 1 and 2 are full, then add it to slot 3 (slot clicked on)
                else if indexPath.row == 2 && self.models[2] == "empty slot"{
                    self.models[indexPath.row] = "\(addedCode)"
                    self.tableView.reloadData()
                }
                
                //(when slot 2 clicked on) if slot 1 is open, then add it to slot 1
                else if indexPath.row == 1 && self.models[0] == "empty slot" {
                    self.models[indexPath.row - 1] = "\(addedCode)"
                    self.tableView.reloadData()
                }
                
                //(when slot 2 clicked on) if slot 1 is full, then add it to slot 2 (slot clicked on)
                else if indexPath.row == 1 && self.models[1] == "empty slot"{
                    self.models[indexPath.row] = "\(addedCode)"
                    self.tableView.reloadData()
                }
                
                //(when slot 1 clicked on) if slot 1 is open, then add it to slot 1 (slot clicked on)
                else if indexPath.row == 0 && self.models[0] == "empty slot" {
                    self.models[indexPath.row] = "\(addedCode)"
                    self.tableView.reloadData()
                }
                
            }))
            
            alertMessage.addTextField { field in
                field.placeholder = "Enter the code here"
                field.returnKeyType = .done
                field.keyboardType = .numberPad
            }

            self.present(alertMessage, animated: true, completion: nil)
        }
        
        // Add Deleting a code action
        let deleteActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Delete a code", message: "Re-enter the 4 digit that will be deleted", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertMessage.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [indexPath] _ in
                guard let fields = alertMessage.textFields, let deleteCodeField = fields.first,
                      let deletedCode = deleteCodeField.text, deletedCode.count == 4, deletedCode == self.models[indexPath.row] else {
                    print("invalid entry")
                    
                    let alertInvalidEntry = UIAlertController(title: "Invalid Entry", message: "Make sure that the code you want to delete matches the code in that slot", preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertInvalidEntry.addAction(okayAction)
                    self.present(alertInvalidEntry, animated: true, completion: nil)
                    return
                }
                print("The deleted code is: \(deletedCode)")
                
                let alertSuccess = UIAlertController(title: "Success!", message: "Your code has been deleted.", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertSuccess.addAction(okayAction)
                self.present(alertSuccess, animated: true, completion: nil)
                
                //Call the write function on the source view controller
                if SingletonClass.shared.curPeripheral != nil{
                    print("curPeripheral is not nil")
                    if SingletonClass.shared.srcharacteristic != nil{
                        print("srcharacreristic is not nil")
                        self.sourceVC.write(data: "123455S2")
                        SingletonClass.shared.waitingOn = "B"
                        self.sourceVC.write(data: "\(deletedCode)")
                        SingletonClass.shared.waitingOn = "B"
                        self.sourceVC.write(data: "\(deletedCode)")
                        SingletonClass.shared.waitingOn = "A"
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.sourceVC.write(data: "U")
                }
                self.models[indexPath.row] = "empty slot"
                self.tableView.reloadData()
                
            }))
            alertMessage.addTextField { field in
                field.placeholder = "Enter the code here"
                field.returnKeyType = .done
                field.keyboardType = .numberPad
            }
            self.present(alertMessage, animated: true, completion: nil)
        }
        
        let addCodeAction = UIAlertAction(title: "Add New Code in slot # \(indexPath.row + 1)", style: .default, handler: addActionHandler)
        let deleteCodeAction = UIAlertAction(title: "Delete Existing Code # \(indexPath.row + 1)", style: .default, handler: deleteActionHandler)
        
        
        // Add new actions based on the updated conditions
        if indexPath.row == 0 {
            if SingletonClass.shared.entryCode1 == "empty slot" {
                optionMenu.addAction(addCodeAction)
            } else {
                optionMenu.addAction(deleteCodeAction)
            }
        } else if indexPath.row == 1 {
            if SingletonClass.shared.entryCode2 == "empty slot" {
                optionMenu.addAction(addCodeAction)
            } else {
                optionMenu.addAction(deleteCodeAction)
            }
        } else if indexPath.row == 2 {
            if SingletonClass.shared.entryCode3 == "empty slot" {
                optionMenu.addAction(addCodeAction)
            } else {
                optionMenu.addAction(deleteCodeAction)
            }
        }
        
        optionMenu.addAction(cancelAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }

}


