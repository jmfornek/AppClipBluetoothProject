//
//  SecondViewController.swift
//  TestClip1
//
//  Created by Jason Fornek on 2/7/23.
//

import UIKit
import Foundation
import CoreBluetooth

class SecondViewController: UIViewController, CBPeripheralDelegate {
    
    @IBOutlet weak var connectedToLbl2: UILabel!
    @IBOutlet weak var connectionSymbol2: UIImageView!
    @IBOutlet weak var TestSegueLbl: UILabel!
    
//    var entryCode1: String = ""
//    var code1passer: String = ""
//    var entryCode2: String = ""
//    var code2passer: String = ""
//    var entryCode3: String = ""
//    var code3passer: String = ""
    
    // Create a delegate variable
    weak var delegate: CodeEntryProtocol?
    
    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        TestSegueLbl.text = "The data passed is: \(entryCode1)"
        TestSegueLbl.textColor = UIColor.blue
//        code1passer = entryCode1
//        code2passer = entryCode2
//        code3passer = entryCode3
    }
    
    @IBAction func sendData(_ sender: Any) {
            // Call the transferData function
            let data = "Hello, world!"
            delegate?.transferData(data: data)
    }
    
    @IBAction func manageCodesButton() {
        print("the manage codes button was pressed")
//        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "manageCodesScreen") as? TableViewController else{
//            return
//        }
//        self.navigationController?.pushViewController(storyboard, animated: true)
        
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! TableViewController
//        vc.code1passer = self.code1passer
//        let vc2 = segue.destination as! TableViewController
//        vc2.code2passer = self.code2passer
//        let vc3 = segue.destination as! TableViewController
//        vc3.code3passer = self.code3passer
//    }
}

extension SecondViewController: CodeEntryProtocol {
    func transferData(data: Any) {
        // Implement the transferData function
    }
    func write(data: String) {
        
    }
}


