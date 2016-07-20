//
//  NewRebateViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

//
//  NewRebateViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class NewRebateViewController: UIViewController {
    
    var selectedRebate = String()
    var lastSubtotal = Int()
    let firebaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var receiptTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedRebate
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSaveBtnPressed(sender: UIBarButtonItem) {
        self.addRebate()
    }
    
    
    func addRebate() {
        let receiptID = NSUUID().UUIDString
        let rebateRef = firebaseRef.child("Rebate").child(User.currentUserId()!).child(selectedRebate)
        
        guard dateTextField.text != nil && amountTextField.text != nil else {return }
        
        let addedAmount = Int(amountTextField.text!)
        
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if let rebate = Rebate(snapshot: snapshot) {
                self.lastSubtotal = rebate.subTotal
            }
        })
        
        let subtotal = self.lastSubtotal + addedAmount!
        let rebateDict = ["subtotal": subtotal, "receiptID": [receiptID:true]]
        rebateRef.setValue(rebateDict)
        
        let receiptRef = firebaseRef.child("Receipt").child(User.currentUserId()!)
        
        let receiptDict = ["date": dateTextField.text!, "amount": addedAmount!, "receipt no": receiptTextField.text!]
        receiptRef.child(receiptID).setValue(receiptDict)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

