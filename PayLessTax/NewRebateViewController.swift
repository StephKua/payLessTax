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
    
    var selectedRebate: Rebate
    let firebaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var receiptTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedRebate.rebateName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addRebate() {
        let rebateRef = firebaseRef.child("Rebate").child(User.useruid()).child(selectedRebate)
        
        guard let dateTextField != nil, let amountTextField != nil else {return }
        
        let addedAmount = amountTextField.text as? Int
        let subtotal = selectedRebate.rebatePoints + addedAmount
        let rebateDict = ["subtotal": subtotal]
        rebateRef.setValue(rebateDict)
        
        let receiptRef = firebaseRef.child("Receipt").childByAutoId()
        let receiptDict = ["date": dateTextField.text, "amount": addedAmount, "receipt no": receiptTextField.text]
        receiptRef.setValue(receiptDict)
    
        
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
