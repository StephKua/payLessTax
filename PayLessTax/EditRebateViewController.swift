//
//  EditRebateViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 26/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class EditRebateViewController: UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var rebateTypeTextField: UITextField!
    @IBOutlet weak var receiptNoTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    var rebReceipt: Receipt?
    
    var edit = false
    var firebaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let title = rebReceipt?.category, let date = rebReceipt?.date, let rebateType = rebReceipt?.category, let receiptNo = rebReceipt?.receiptNo, let amount = rebReceipt?.amount else { return }
        
        self.disableEdit()
        
        self.title = title
        self.dateTextField.text = date
        self.rebateTypeTextField.text = rebateType
        self.receiptNoTextField.text = receiptNo
        self.amountTextField.text = "\(amount)"
        
    }

    @IBAction func onEditBtnPressed(sender: UIButton) {
        if edit == true {
            self.disableEdit()
            sender.setTitle("Edit", forState: UIControlState.Normal)
            self.edit = false
            self.updateRebate()
            
        } else {
            self.enableEdit()
            sender.setTitle("Save", forState: UIControlState.Normal)
            self.edit = true
            
        }
    }
    
    
    func updateRebate() {
        guard let date = rebReceipt?.date, let rebateType = rebReceipt?.category, let receiptNo = rebReceipt?.receiptNo, let amount = rebReceipt?.amount, let receiptID = rebReceipt?.key else { return }
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "receipt no": receiptNo, "amount": amount, "category": rebateType]
        receiptRef.setValue(receiptDict)
        print(receiptDict)
        
    }

    func enableEdit () {
        self.dateTextField.userInteractionEnabled = true
        self.rebateTypeTextField.userInteractionEnabled = true
        self.receiptNoTextField.userInteractionEnabled = true
        self.amountTextField.userInteractionEnabled = true
        
        self.dateTextField.backgroundColor = UIColor.whiteColor()
        self.rebateTypeTextField.backgroundColor = UIColor.whiteColor()
        self.receiptNoTextField.backgroundColor = UIColor.whiteColor()
        self.amountTextField.backgroundColor = UIColor.whiteColor()
        
    }
    
    func disableEdit () {
        self.dateTextField.userInteractionEnabled = false
        self.rebateTypeTextField.userInteractionEnabled = false
        self.receiptNoTextField.userInteractionEnabled = false
        self.amountTextField.userInteractionEnabled = false
        
        let color = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        self.dateTextField.backgroundColor = color
        self.rebateTypeTextField.backgroundColor = color
        self.receiptNoTextField.backgroundColor = color
        self.amountTextField.backgroundColor = color
        
    }

    
}
