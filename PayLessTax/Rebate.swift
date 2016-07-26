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
    var booksSubTotal = 0
    var donationsSubTotal = 0
    var sportsSubTotal = 0
    var receiptsID = [String:Bool]()
    
    init?(snapshot: FIRDataSnapshot) {
        guard let rebateDict = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        
        if let booksDict = rebateDict["Books"] as? [String: AnyObject], let subtotal = booksDict["subtotal"] as? Int {
            self.booksSubTotal = subtotal
        }
        
        if let donationsDict = rebateDict["Donations"] as? [String: AnyObject], let subtotal = donationsDict["subtotal"] as? Int {
            self.donationsSubTotal = subtotal
        }
        
        if let sportsDict = rebateDict["Sports"] as? [String: AnyObject], let subtotal = sportsDict["subtotal"] as? Int {
            self.sportsSubTotal = subtotal
        }
        

        if let receipt = rebateDict["receipts"] as? [String: Bool] {
            receiptsID = receipt
        } else {
            receiptsID = [:]
        }
        
    }
    
    
}