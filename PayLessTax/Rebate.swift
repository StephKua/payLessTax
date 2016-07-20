//
//  Rebate.swift
//  PayLessTax
//
//  Created by Skkz on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation
import Firebase

class Rebate {
    var rebateName = String()
    var rebatePoints = Int()
    var rebateMaxPoints = 1000
    var subTotal = 0
    
    init?(snapshot: FIRDataSnapshot) {
        guard let rebateDict = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        
        if let name = rebateDict["rebateName"] as? String {
            self.rebateName = name
        }
        
        if let point = rebateDict["rebatePoints"] as? Int {
            if point == 0 {
                self.rebatePoints = 0
            } else {
                self.rebatePoints = point
            }
        }
        
        if let subTotal = rebateDict["subtotal"] as? Int {
            if subTotal == 0 {
                self.subTotal = 0
            } else {
                self.subTotal += subTotal
            }
        }
        
    }
    
    
}