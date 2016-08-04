//
//  UserRebateCategory.swift
//  PayLessTax
//
//  Created by Sheena Moh on 02/08/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class UserRebateCategory: NSObject {
    var categoryName = ""
    var receiptUIDs = [String]()
    var receipts = [Receipt]()
    var subTotal: Double = 0
    
    init?(snapshot: FIRDataSnapshot){
        guard let dict = snapshot.value as? [String: AnyObject] else {return}
        
        categoryName = snapshot.key
        
        if let uids = dict["receiptID"] as? [String: Bool]{
            receiptUIDs = Array(uids.keys)
        }
        
        if let subTotal = dict["subtotal"] as? Double{
            self.subTotal = subTotal
        }
        
    }
    
    func downloadReceiptDetails(completion: () -> ()){
        let receiptRef = FIRDatabase.database().reference().child("receipt")
        for uid in receiptUIDs{
            receiptRef.child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let receipt = Receipt(snapshot: snapshot){
                    self.receipts.append(receipt)
                    completion()
                }
            })
        }
    }
}


