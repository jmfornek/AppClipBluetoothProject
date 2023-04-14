//
//  SingletonClass.swift
//  TestClip1
//
//  Created by Jason Fornek on 3/1/23.
//

import UIKit
import CoreBluetooth

class SingletonClass {
    static let shared = SingletonClass()
    
    var curPeripheral: CBPeripheral?
    var srcharacteristic: CBCharacteristic?
    var waitingOn: String?
    var entryCode1: String?
    var entryCode2: String?
    var entryCode3: String?
    
    private init() {}
    
    
}
