//
//  Rebate.swift
//  PayLessTax
//
//  Created by Sheena Moh on 20/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//


import Foundation
import Firebase

class Rebate {
    var rebateMaxPoints = 1000
    var subTotal = 0
    var receiptsID = [String:Bool]()
    
    init?(snapshot: FIRDataSnapshot) {
        guard let rebateDict = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        
        if let subTotal = rebateDict["subtotal"] as? Int {
            if subTotal == 0 {
                self.subTotal = 0
            } else {
                self.subTotal += subTotal
            }
        }
        
        if let receipt = rebateDict["receipts"] as? [String: Bool] {
            receiptsID = receipt
        } else {
            receiptsID = [:]
        }
        
    }
    
    
}