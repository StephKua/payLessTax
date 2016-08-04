//
//  RebateCategories.swift
//  PayLessTax
//
//  Created by Sheena Moh on 01/08/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation
import Firebase

class RebateCategories: NSObject {
    var key = String()
    var title = String()
    var details = String()
    var max = String()
    var imageUrl = String()
    var subtotal = Int()
    
    
    init? (snapshot: FIRDataSnapshot) {
        guard let rebateCatDict = snapshot.value as? [String: AnyObject] else { return nil }
        
        if let key = snapshot.key as? String {
            self.key = key
        }
        
        if let title = rebateCatDict["catName"] as? String {
            self.title = title
        }
        
        if let details = rebateCatDict["catDesc"] as? String {
            self.details = details
        }
        
        if let max = rebateCatDict["catAmount"] as? String {
            self.max = max
        }
        
        if let image = rebateCatDict["imageURL"] as? String {
            self.imageUrl = image
        }
        
        if let subtotal = rebateCatDict["subtotal"] as? [String: Int]{
            for (key, value) in subtotal {
                if key == User.currentUserId() {
                    self.subtotal = value
                }
            }
        }
    }
}