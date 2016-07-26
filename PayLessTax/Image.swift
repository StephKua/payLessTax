//
//  Image.swift
//  PayLessTax
//
//  Created by Sheena Moh on 22/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation
import Firebase

class Image {
    var imageURL: String!
    var userUID: String!
    var userName: String?
    
    var user: User?
    
    init?(snapshot: FIRDataSnapshot) {
        guard let imageDict = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        
        imageURL = imageDict["imageURL"] as! String
        userUID = imageDict["userID"] as! String
        
    }
    
}