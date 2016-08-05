//
//  Validation.swift
//  PayLessTax
//
//  Created by Sheena Moh on 04/08/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation

class Validation {
    static func isStringNumerical(string : String) -> Bool {
        // Only allow numbers. Look for anything not a number.
        let range = string.rangeOfCharacterFromSet(NSCharacterSet.letterCharacterSet().invertedSet)
        return (range == nil)
    }
}