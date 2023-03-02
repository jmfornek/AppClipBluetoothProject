//
//  ViewController.swift
//  iOS BLE
//
//  Created by jasonfornek on 10/26/22.
//
// Import necessary modules

import UIKit
import Foundation
import CoreBluetooth

// Initialize global variables
var curPeripheral: CBPeripheral?
var srcharacteristic: CBCharacteristic?
//var txCharacteristic: CBCharacteristic?
//var rxCharacteristic: CBCharacteristic?

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Variable Initializations
    var centralManager: CBCentralManager!
    var rssiList = [NSNumber]()
    var peripheralList: [CBPeripheral] = []
    var characteristicList = [String: CBCharacteristic]()
    var characteristicValue = [CBUUID: NSData]()
    var timer = Timer()
    var curPeripheral: CBPeripheral?
    
    //Since we have a white background, this overrides the white background and displays black text in the status bar (time, 5G, wifi, etc.)
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .darkContent
    }
    
    //let BLE_Service_UUID = CBUUID.init(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e") // Feather nRF52832 (Adafruit)
    let BLE_Service_UUID = CBUUID.init(string: "0000FFE0-0000-1000-8000-00805F9B34FB") // service UUID of HM10 (good)
    //let BLE_Characteristic_uuid_Rx = CBUUID.init(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e") // Rx of Adafruit
    //let BLE_Characteristic_uuid_Rx = CBUUID.init(string: "0000FFE1-0000-1000-8000-00805F9B34FB") // rx characteristic of HM10 (good)
    //let BLE_Characteristic_uuid_Tx  = CBUUID.init(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e") //Tx of Adafruit
    //let BLE_Characteristic_uuid_Tx = CBUUID.init(string: "0000FFE1-0000-1000-8000-00805F9B34FB") //tx characteristic of HM10 (good)
    let characteristicUUID = CBUUID(string: "FFE1") // new declaration of characteristic
    
    // @IBOutlet weak var connectStatusLbl: UILabel!
    //var receivedData = [Int]()
    // var showGraphIsOn = true
    
    //@IBOutlet weak var showGraphLbl: UILabel!
    @IBOutlet weak var connectedToLbl: UILabel!
    @IBOutlet weak var connectionSymbol: UIImageView!
    
    //@IBOutlet weak var DataReceivedfromArduino: UILabel!
    
    @IBOutlet weak var PairingModeButton: UIButton!
    

    // This function is called before the storyboard view is loaded onto the screen.
    // Runs only once.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize CoreBluetooth Central Manager object which will be necessary
        // to use CoreBlutooth functions
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // This function is called right after the view is loaded onto the screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reset the peripheral connection with the app
        if curPeripheral != nil {
            centralManager?.cancelPeripheralConnection(curPeripheral!)
        }
        print("View Cleared")
    }
    
    @IBAction func PairingModeButton (_ sender: Any) {
        
        startScan()
        write(data: "This message was sent successfully")
        //let dataToSend = "Hello, HM10!".data(using: .utf8)
        //peripheral.writeValue(dataToSend!, for: srcharacteristic, type: .withoutResponse)
    }
    

    // This function is called right before view disappears from screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Stop Scanning")
        
        // Central Manager object stops the scanning for peripherals
        centralManager?.stopScan()
    }
    
    // Called when manager's state is changed
    // Required method for setting up centralManager object
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        // If manager's state is "poweredOn", that means Bluetooth has been enabled
        // in the app. We can begin scanning for peripherals
        if central.state == CBManagerState.poweredOn {
            print("Bluetooth Enabled")
            //startScan()
        }
        
        // Else, Bluetooth has NOT been enabled, so we display an alert message to the screen
        // saying that Bluetooth needs to be enabled to use the app
        else {
            print("Bluetooth Disabled- Make sure your Bluetooth is turned on")
            
            let alertVC = UIAlertController(title: "Bluetooth is not enabled",
                                            message: "Make sure that your bluetooth is turned on",
                                            preferredStyle: UIAlertController.Style.alert)
            
            let action = UIAlertAction(title: "ok",
                                       style: UIAlertAction.Style.default,
                                       handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            alertVC.addAction(action)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // Start scanning for peripherals
    func startScan() {
        print("Now Scanning...")
        print("Service ID Search: \(BLE_Service_UUID)")
        
        // Make an empty list of peripherals that were found
        peripheralList = []
        
        // Stop the timer
        self.timer.invalidate()
        
        // Call method in centralManager class that actually begins the scanning.
        // We are targeting services that have the same UUID value as the BLE_Service_UUID variable.
        // Use a timer to wait 10 seconds before calling cancelScan().
        centralManager?.scanForPeripherals(withServices: [BLE_Service_UUID],
                                           options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            self.cancelScan()
        }
    }
    
    // Cancel scanning for peripheral
    func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripheralList.count)")
        
    }
    
//    @IBAction func Buttonpressed(_ sender: Any) {
//
//        print("button was pressed")
//        write(data: "Button was pressed! And the arduino has received the data successfully\n")
//    }

    //Declares our homemade write function
    func write(data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let curPeripheral = curPeripheral{
            if let srcharacteristic = srcharacteristic{
                curPeripheral.writeValue(valueString!, for: srcharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    
    
        // Called when a peripheral is found.
        func centralManager(_ central: CBCentralManager,
                            didDiscover peripheral: CBPeripheral,
                            advertisementData: [String : Any],
                            rssi RSSI: NSNumber) {
            
            // The peripheral that was just found is stored in a variable and
            // is added to a list of peripherals. Its rssi value is also added to a list
            curPeripheral = peripheral
            self.peripheralList.append(peripheral)
            self.rssiList.append(RSSI)
            peripheral.delegate = self
            
            // Connect to the peripheral if it exists / has services
            if curPeripheral != nil {
                centralManager?.connect(curPeripheral!, options: nil)
            }
        }
        
        // Restore the Central Manager delegate if something goes wrong
        func restoreCentralManager() {
            centralManager?.delegate = self
        }
        
        // Called when app successfully connects with the peripheral
        // Use this method to set up the peripheral's delegate and discover its services
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("-------------------------------------------------------")
            print("Connection complete")
            print("Peripheral info: \(String(describing: curPeripheral))")
            
            // Stop scanning because we found the peripheral we want
            cancelScan()
            
            // Set up peripheral's delegate
            peripheral.delegate = self
            
            // Only look for services that match our specified UUID
            peripheral.discoverServices([BLE_Service_UUID])
        }
        
        // Called when the central manager fails to connect to a peripheral
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            
            // Print error message to console for debugging purposes
            if error != nil {
                print("Failed to connect to peripheral")
                return
            }
        }
        
        // Called when the central manager disconnects from the peripheral
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            print("Disconnected")
            //connectStatusLbl.text = "Disconnected"
            //connectStatusLbl.textColor = UIColor.red
            connectedToLbl.text = "No Connection"
            connectedToLbl.textColor = UIColor.red
            connectionSymbol.image = UIImage(named: "redXsymbol")   // displays a red X on the device
            
            
        }
        
        // Called when the correct peripheral's services are discovered
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("-------------------------------------------------------")
            
            // Check for any errors in discovery
            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            
            // Store the discovered services in a variable. If no services are there, return
            guard let services = peripheral.services else {
                return
            }
            
            // Print to console for debugging purposes
            print("Discovered Services: \(services)")
            
            // For every service found...
            for service in services {
                
                // If service's UUID matches with our specified one...
                if service.uuid == BLE_Service_UUID {
                    print("Service found")
                    //connectStatusLbl.text = "Connected!"
                    //connectStatusLbl.textColor = UIColor.blue
                    connectedToLbl.text = "Connected to \(String(describing: curPeripheral?.name))"
                    connectedToLbl.textColor = UIColor.blue
                    connectionSymbol.image = UIImage(named: "checkmarkflat") // displays a green checkmark on the device
                    
                    write(data: "U")
                    
                    
                    guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController else{
                        return
                    }
                    self.navigationController?.pushViewController(storyboard, animated: true)
                    
                    
                    
                    
                    
                    // Search for the characteristics of the service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
        
        // Called when the characteristics we specified are discovered
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            print("-------------------------------------------------------")
            
            // Check if there was an error
            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            
            //Store the discovered characteristics in a variable. If no characteristics, then return
            guard let characteristics = service.characteristics else {
                return
            }
//            guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
//                print("Characteristic not found")
//                return
//            }
            

            // Print to console for debugging purposes
            print("Found \(characteristics.count) characteristics!")

            // For every characteristic found...
            for characteristic in characteristics {
                
                
                // If characteritstic's UUID matches with our specified one for Rx...
                if characteristic.uuid.isEqual(characteristicUUID)  {
                    srcharacteristic = characteristic
                    
                    // Subscribe to the this particular characteristic
                    // This will also call didUpdateNotificationStateForCharacteristic
                    // method automatically
                    peripheral.setNotifyValue(true, for: srcharacteristic!)
                    peripheral.readValue(for: characteristic)
                    print("Rx Characteristic: \(characteristic.uuid)")
                    print("Tx Characteristic: \(characteristic.uuid)")
                }
                
                // Save the characteristic
                //self.srcharacteristic = characteristic

                
                // Find descriptors for each characteristic
                peripheral.discoverDescriptors(for: characteristic)
            }
        }
    
    
    
    
    
        // Sets up notifications to the app from the Feather
        // Calls didUpdateValueForCharacteristic() whenever characteristic's value changes
        func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            print("*******************************************************")
            
            // Check if subscription was successful
            if (error != nil) {
                print("Error changing notification state:\(String(describing: error?.localizedDescription))")
                
            } else {
                print("Characteristic's value subscribed")
            }
            
            // Print message for debugging purposes
            if (characteristic.isNotifying) {
                print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
            }
        }
        
        // Called when peripheral.readValue(for: characteristic) is called
        // Also called when characteristic value is updated in
        // didUpdateNotificationStateFor() method
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                        error: Error?) {
            
            // If characteristic is correct, read its value and save it to a string.
            // Else, return
            guard characteristic == srcharacteristic,
                  let characteristicValue = characteristic.value,
                  let receivedString = NSString(data: characteristicValue,
                                                encoding: String.Encoding.utf8.rawValue)
            else { return }
            
            //DataReceivedfromArduino.text = "Data Received: " + (receivedString as String)
            //DataReceivedfromArduino.textColor = UIColor.blue
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: self)
            

            //Remove the single quotes and carriage return from the string
            let cleanStr = receivedString.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "\n", with: "")

            // Split the string into three parts using the comma separator
            let array = cleanStr.split(separator: ",")

            // Define the three separate arrays
            let array1 = String(array[0])
            let array2 = String(array[1])
            let array3 = String(array[2])

            print("array #1: \(array1)")
            print("array #2: \(array2)")
            print("array #3: \(array3)")

            peripheral.setNotifyValue(false, for: characteristic)
            
        }

    
    
        // Called when app wants to send a message to peripheral
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            guard error == nil else {
                print("Error discovering services: error")
                return
            }
            print("Message sent")
            //write(data: "Button was pressed")
        }
        
        
        
        
        // Called when descriptors for a characteristic are found
        func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
            
            // Print for debugging purposes
            print("*******************************************************")
            if error != nil {
                print("\(error.debugDescription)")
                return
            }
            
            // Store descriptors in a variable. Return if nonexistent.
            guard let descriptors = characteristic.descriptors else { return }
            
            // For every descriptor, print its description for debugging purposes
            descriptors.forEach { descript in
                print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
                print("Rx Value \(String(describing: srcharacteristic?.value))")
                print("Tx Value \(String(describing: srcharacteristic?.value))")
            }
        }
    



}


/*
// trying entire new bluetooth code from ChatGPT
import CoreBluetooth
import UIKit

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    // HM10 BLE module's service and characteristic UUIDs
    let serviceUUID = CBUUID(string: "FFE0")
    let characteristicUUID = CBUUID(string: "FFE1")

//    @IBOutlet weak var connectedToLbl: UILabel!
//    @IBOutlet weak var connectionSymbol: UIImageView!
//
//    @IBAction func PairingModeButton (_ sender: Any) {
//
//        write(data: "This message was sent successfully")
//
//    }


    // Central manager and peripheral objects
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!

    // Characteristic to write data to
    var characteristic: CBCharacteristic?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the central manager and set ourselves as the delegate
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Called when the central manager's state is updated
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Check if Bluetooth is powered on
        if central.state == .poweredOn {
            // Scan for peripherals with the service UUID we're interested in
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            // Bluetooth is not powered on or is not available on this device
            print("Bluetooth is not available")
        }
    }

    // Called when a peripheral is discovered during scanning
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Stop scanning
        central.stopScan()

        // Save the peripheral
        self.peripheral = peripheral

        // Set ourselves as the peripheral's delegate
        peripheral.delegate = self

        // Connect to the peripheral
        central.connect(peripheral, options: nil)
    }

    // Called when the central manager successfully connects to a peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Discover the peripheral's services
        peripheral.discoverServices([serviceUUID])
    }

    // Called when the peripheral's services are discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Check for errors
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        // Find the service we're interested in
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            print("Service not found")
            return
        }

        // Discover the service's characteristics
        peripheral.discoverCharacteristics([characteristicUUID], for: service)
        
    }

    // Called when the peripheral's characteristics are discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Check for errors
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }

        // Find the characteristic we're interested in
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            print("Characteristic not found")
            return
        }

        // Save the characteristic
        self.characteristic = characteristic

        // Write data to the characteristic
        write(data: "This was successfully written")
    }
    
    func write(data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let peripheral = peripheral{
            if let characteristic = characteristic{
                peripheral.writeValue(valueString!, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    
}
*/
