//
//  User.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User: NSObject {
    
    class func signIn (uid: String) {
        NSUserDefaults.standardUserDefaults().setValue(uid, forKey: "uid")
        
    }
    
    class func isSignedIn () -> Bool {
        if let _ = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String {
            return true
        } else {
            return false
        }
    }
    
    class func currentUserId() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
    }
    
    class func removeUserUid () {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("uid")
    }
    
}