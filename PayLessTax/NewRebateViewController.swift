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
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func addRebate() {
        guard let date = dateTextField.text, let receiptNo = receiptTextField.text, let amount = amountTextField.text else { return }
        
        var amountAdded = Int()
        if amount != "" {
            amountAdded = Int(amount)!
        }
        
        let receiptID = NSUUID().UUIDString
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "receipt no": receiptNo, "amount": amountAdded, "category": selectedRebate]
        receiptRef.setValue(receiptDict)
        
        
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(selectedRebate)
        rebateRef.child("receiptID").child(receiptID).setValue(true)
        
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                if let oldValue = rebateTypeDict["subtotal"] as? Int {
                    rebateTypeDict["subtotal"] = oldValue + amountAdded
                } else {
                    rebateTypeDict["subtotal"] = amountAdded
                }
                rebateRef.updateChildValues(rebateTypeDict)
            }
        })        
    }
    
}

