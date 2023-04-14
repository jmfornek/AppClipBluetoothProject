import UIKit
import Foundation
import CoreBluetooth

class TableViewController: UITableViewController, CBPeripheralDelegate {

    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }

    var textFields: [UITextField]?
//    var code1passer: String = ""
//    var code2passer: String = ""
//    var code3passer: String = ""
//    public var entryCode1: String?
//    public var entryCode2: String?
//    public var entryCode3: String?
    var sourceVC: ViewController = ViewController()
    var curPeripheral: CBPeripheral?
    var srcharacteristic: CBCharacteristic?
    
    
    // Create a delegate variable
    weak var delegate: CodeEntryProtocol?

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if let sourceViewController = segue.source as? ViewController {
//                sourceViewController.delegate = self
//            }
//    }
    
    var models: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        models = ["Entry code 1: \(SingletonClass.shared.entryCode1!)", "Entry code 2: \(SingletonClass.shared.entryCode2!)", "Entry code 3: \(SingletonClass.shared.entryCode3!)"]

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create an option menu as an action sheet, change ".actionSheet to .alert if we want to display an alert style
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add action to the menu
        let cancelAction  = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add Add-code action
        let addActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Add a code", message: "Enter a 4 digit code", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertMessage.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                guard let fields = alertMessage.textFields, let addCodeField = fields.first,
                      let addedCode = addCodeField.text, addedCode.count == 4 else {
                    print("invalid entry")
                    return
                }
                print("The added code is: \(addedCode)")
                
            
                //Call the write function on the source view controller
                if SingletonClass.shared.curPeripheral != nil{
                    print("curPeripheral is not nil")
                    if SingletonClass.shared.srcharacteristic != nil{
                        print("srcharacreristic is not nil")
                        self.sourceVC.write(data: "123455S1")
                        self.sourceVC.write(data: "\(addedCode)")
                        SingletonClass.shared.waitingOn = "B"
                        self.sourceVC.write(data: "\(addedCode)")
                        SingletonClass.shared.waitingOn = "B"
                    }
                }
                
                
                self.models[indexPath.row] = "Entry code \(indexPath.row + 1): \(addedCode)"
                self.tableView.reloadData()
            }))
            
            alertMessage.addTextField { field in
                field.placeholder = "Enter the code here"
                field.returnKeyType = .done
                field.keyboardType = .numberPad
            }
//            if let presentingVC = self.presentingViewController as? ViewController {
//                self.delegate = presentingVC
//            }
            self.present(alertMessage, animated: true, completion: nil)
        }
        
        // Add Deleting a code action
        let deleteActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Delete a code", message: "Re-enter the 4 digit that will be deleted", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertMessage.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                guard let fields = alertMessage.textFields, let deleteCodeField = fields.first,
                      let deletedCode = deleteCodeField.text, deletedCode.count == 4 else {
                    print("invalid entry")
                    return
                }
                print("The deleted code is: \(deletedCode)")
                
                //Call the write function on the source view controller
                if SingletonClass.shared.curPeripheral != nil{
                    print("curPeripheral is not nil")
                    if SingletonClass.shared.srcharacteristic != nil{
                        print("srcharacreristic is not nil")
                        self.sourceVC.write(data: "123455S2")
                        self.sourceVC.write(data: "\(deletedCode)")
                        SingletonClass.shared.waitingOn = "B"
                        self.sourceVC.write(data: "\(deletedCode)")
                        SingletonClass.shared.waitingOn = "B"
                    }
                }
                
                
                self.models[indexPath.row] = "Entry code \(indexPath.row + 1): empty slot"
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
        


//        if  indexPath.row == 0 && SingletonClass.shared.entryCode1 == "empty slot" {
//            optionMenu.addAction(addCodeAction)
//        }
//        else if SingletonClass.shared.entryCode1 != "empty slot" {
//            optionMenu.addAction(deleteCodeAction)
//        }
//
//        else if  indexPath.row == 1 && SingletonClass.shared.entryCode2 == "empty slot" {
//            optionMenu.addAction(addCodeAction)
//        }
//        else if SingletonClass.shared.entryCode2 != "empty slot" {
//            optionMenu.addAction(deleteCodeAction)
//        }
//        else if  indexPath.row == 2 && SingletonClass.shared.entryCode3 == "empty slot" {
//            optionMenu.addAction(addCodeAction)
//        }
//        else if SingletonClass.shared.entryCode3 != "empty slot" {
//            optionMenu.addAction(deleteCodeAction)
//        }
        
        
        for i in 0..<models.count {
            if models[i].contains("empty slot"){
                optionMenu.addAction(addCodeAction)
            }
            if !models[i].contains("empty slot") {
                optionMenu.addAction(deleteCodeAction)
            }
        }
        
        optionMenu.addAction(cancelAction)
        
        // Display the menu
        present(optionMenu, animated: true, completion: nil)
    }

}

extension TableViewController: CodeEntryProtocol {
    func transferData(data: Any) {
        // Implement the transferData function
    }
    func write(data: String) {
//        print("The write function protocol was reached")
//        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
//        if let curPeripheral = curPeripheral{
//            if let srcharacteristic = srcharacteristic{
//                curPeripheral.writeValue(valueString!, for: srcharacteristic, type: CBCharacteristicWriteType.withoutResponse)
//            }
//        }
//        print("the write function protocol ended")
    }
    
}


/*
 //        let addActionHandler = { [weak self] (action: UIAlertAction!) -> Void in
 //            guard let self = self else { return }
 //            let alertMessage = UIAlertController(title: "Add a code", message: "Enter a 4 digit code", preferredStyle: .alert)
 //            alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
 //            alertMessage.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
 //                guard let fields = alertMessage.textFields, let addCodeField = fields.first,
 //                      let addedCode = addCodeField.text, addedCode.count == 4 else {
 //                    print("invalid entry")
 //                    return
 //                }
 //                print("The added code is: \(addedCode)")
 //                //self.delegate?.write(data: "P")
 //                self.models[indexPath.row] = "Entry code \(indexPath.row + 1): \(addedCode)"
 //                self.tableView.reloadData()
 //            }))
 //
 //            alertMessage.addTextField { field in
 //                field.placeholder = "Enter the code here"
 //                field.returnKeyType = .done
 //                field.keyboardType = .numberPad
 //            }
 //
 //            if let presentingVC = self.presentingViewController as? ViewController {
 //                self.delegate = presentingVC
 //            }
 //
 //            self.present(alertMessage, animated: true, completion: nil)
 //        }
 */
