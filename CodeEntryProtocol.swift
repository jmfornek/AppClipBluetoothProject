//
//  DataTransferProtocol.swift
//  TestClip1
//
//  Created by Jason Fornek on 3/28/23.
//

import Foundation
import CoreBluetooth

// Define the protocol
protocol CodeEntryProtocol: AnyObject {
    // Define the function to transfer data
    func transferData(data: Any)
    func write(data: String)
}
