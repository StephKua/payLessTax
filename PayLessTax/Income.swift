//
//  Income.swift
//  PayLessTax
//
//  Created by Sheena Moh on 20/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation
import Firebase

class Income {
    
    var incomeCat: String?
    var employmentSubTotal = 0
    var rentalSubTotal = 0
    var othersSubTotal = 0
    var receiptID = [String: Bool]()
    
    init?(snapshot: FIRDataSnapshot) {
        guard let incomeDict = snapshot.value as? [String: AnyObject] else { return }
        
        self.incomeCat = snapshot.key
        
        if let employmentDict = incomeDict["Employment"] as? [String: AnyObject], let subtotal = employmentDict["subtotal"] as? Int {
            self.employmentSubTotal = subtotal
        }
        
        if let rentalDict = incomeDict["Rental"] as? [String: AnyObject], let subtotal = rentalDict["subtotal"] as? Int {
            self.rentalSubTotal = subtotal
        }
        
        if let othersDict = incomeDict["Others"] as? [String: AnyObject], let subtotal = othersDict["subtotal"] as? Int {
            self.othersSubTotal = subtotal
        }
        
        
        if let id = incomeDict["receiptID"] as? [String: Bool] {
            self.receiptID = id
        } else {
            self.receiptID = [:]
        }
        
        
    }
    
    
}