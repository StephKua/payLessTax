//
//  Receipt.swift
//  PayLessTax
//
//  Created by Sheena Moh on 20/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Receipt: NSObject {
    
    var amount = 0.0
    var receiptNo = "0"
    var refNo = "0"
    var date = String()
    var category = String()
    var key = String()
    
    init?(snapshot: FIRDataSnapshot) {
        guard let receiptDict = snapshot.value as? [String: AnyObject] else { return }
        
        self.key = snapshot.key
        
        if let receiptNo = receiptDict["receipt no"] as? String {
            self.receiptNo = receiptNo
        }
        
        if let refNo = receiptDict["reference no"] as? String {
            self.refNo = refNo
        }
        
        
        if let amount = receiptDict["amount"] as? Double {
            self.amount = amount
        }
        
        if let date = receiptDict["date"] as? String {
            self.date = date
        }
        
        if let category = receiptDict["category"] as? String {
            self.category = category
        }
        
    }

    
}
