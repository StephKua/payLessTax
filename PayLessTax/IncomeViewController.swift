//
//  IncomeViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class IncomeViewController: UIViewController {
    
    let firebaseRef = FIRDatabase.database().reference()
    var listOfIncome = [Income]()
    var typesOfIncome = [String]()
    
    @IBOutlet weak var employmentLabel: UILabel!
    @IBOutlet weak var rentalLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    
    @IBOutlet weak var totalLabel: UILabel!
    var totalInc = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.typesOfIncome = ["Employment", "Rental", "Others"]
        self.getIncome()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getIncome()
    }
    
    
    func getIncome () {
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!)
        incomeRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let income = Income(snapshot: snapshot) {
                
                self.employmentLabel.text = "RM \(income.employmentSubTotal.asCurrencyNoDecimal)"
                self.rentalLabel.text = "RM \(income.rentalSubTotal.asCurrencyNoDecimal)"
                self.otherLabel.text = "RM \(income.othersSubTotal.asCurrencyNoDecimal)"
                
                self.totalInc = income.employmentSubTotal + income.rentalSubTotal + income.othersSubTotal
                self.totalLabel.text = "RM \(self.totalInc.asCurrencyNoDecimal)"
                
                
            }
        })
    }
    
}
