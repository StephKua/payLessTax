//
//  Section.swift
//  PayLessTax
//
//  Created by Sheena Moh on 21/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import Foundation

struct Section {
    var heading: String
    var items: [String]
    
    init (title: String, objects: [String]) {
        heading = title
        items = objects
    }
}

class SectionsData {
    func getSectionsFromData() -> [Section] {
        
        var sectionsArray = [Section]()
        let deductions = Section(title: "Deductions", objects: ["Books", "Donations", "Sports"])
        let income = Section(title: "Income", objects: ["Employment", "Rental", "Others"])
        
        sectionsArray.append(income)
        sectionsArray.append(deductions)
        
        
        return sectionsArray
    }
}


