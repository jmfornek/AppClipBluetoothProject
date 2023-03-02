//
//  SecondViewController.swift
//  TestClip1
//
//  Created by Jason Fornek on 2/7/23.
//

import UIKit
import Foundation
import CoreBluetooth

class SecondViewController: UIViewController {

    @IBOutlet weak var connectStatusLbl2: UILabel!
    @IBOutlet weak var connectedToLbl2: UILabel!
    @IBOutlet weak var connectionSymbol2: UIImageView!
    
    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func manageCodesButton() {
        print("the manage codes button was pressed")
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "manageCodesScreen") as? TableViewController else{
            return
        }
        self.navigationController?.pushViewController(storyboard, animated: true)
        
    }

}

/*
 //
 //  homepageViewController.swift
 //  appclip
 //
 //  Created by Kara McCarthy on 2/18/23.
 //

 import UIKit
 import Foundation
 import CoreBluetooth


 class homepageViewController: UIViewController {
     
     var centralManager: CBCentralManager!
     var rssiList = [NSNumber]()
     var peripheralList: [CBPeripheral] = []
     var characteristicList = [String: CBCharacteristic]()
     var characteristicValue = [CBUUID: NSData]()
     var timer = Timer()
     var curPeripheral: CBPeripheral?


     @IBOutlet weak var connectedto2Lbl: UILabel!
     
     @IBAction func managecodesBtn(_ sender: Any) {
         guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "manageViewController") as? manageViewController else{
             return
         }
         self.navigationController?.pushViewController(storyboard, animated: true)
         
     }
     
     override func viewDidLoad() {
         super.viewDidLoad()

         connectedto2Lbl.text = "Connected!"
        // connectedLbl.text = "Connected to \(String(describing: curPeripheral?.name))"
         //connectedLbl.textColor = UIColor.blue
         // Do any additional setup after loading the view.
         
     }
 */
