//
//  NewIncomeViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class NewIncomeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let firebaseRef = FIRDatabase.database().reference()
    var lastSubtotal = Int()
    var strDate: String = ""
    var activeTextField: UITextField?
    
    //    @IBOutlet weak var incomePickerView: UIPickerView!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    let pickerData = ["Employment", "Rental", "Others"]
    var selectedData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func onSaveBtnPressed(sender: UIBarButtonItem) {
        self.addIncome()
        self.navigationController?.popViewControllerAnimated(true)
        self.resignFirstResponder()
    }
    
    func addIncome() {
        guard let date = dateTextField.text, let incomeType = incomeTextField.text, let ref = refTextField.text, let amount = amountTextField.text else { return }
        
        var amountAdded = Int()
        if amount != "" {
            amountAdded = Int(amount)!
        }
        
        let receiptID = NSUUID().UUIDString
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "reference no": ref, "amount": amountAdded, "category": incomeType]
        receiptRef.setValue(receiptDict)
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(incomeType)
        
        incomeRef.child("receiptID").child(receiptID).setValue(true)
        
        incomeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var incomeTypeDict = snapshot.value as? [String: AnyObject]{
                if let oldValue = incomeTypeDict["subtotal"] as? Int{
                    incomeTypeDict["subtotal"] = oldValue + amountAdded
                }else{
                    incomeTypeDict["subtotal"] = amountAdded
                }
                incomeRef.updateChildValues(incomeTypeDict)
            }
        })
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        
        let inputView = UIView(frame: CGRectMake(0, 200, view.frame.width, 200))
        inputView.backgroundColor = UIColor.whiteColor()
        
        let datePicker = UIDatePicker(frame: CGRectMake(10, 10, view.frame.width, 200))
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: #selector(NewRebateViewController.donePicker), forControlEvents: UIControlEvents.TouchUpInside)
        
        let incomePickerView = UIPickerView(frame: CGRectMake(10, 10, view.frame.width, 200))
        incomePickerView.backgroundColor = UIColor.clearColor()
        incomePickerView.dataSource = self
        incomePickerView.delegate = self
        incomePickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.translucent = true
        toolbar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolbar.sizeToFit()
        
        let doneBarBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(NewRebateViewController.donePicker))
        let spaceBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelBarBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewRebateViewController.cancelPicker))
        
        toolbar.setItems([cancelBarBtn, spaceBarBtn, doneBarBtn], animated: false)
        toolbar.userInteractionEnabled = true
        
        activeTextField!.inputView = inputView
        activeTextField!.inputAccessoryView = toolbar
        
        switch activeTextField! {
        case dateTextField:
            inputView.addSubview(datePicker)
            handleDatePicker(datePicker)
        case incomeTextField:
            inputView.addSubview(incomePickerView)
        default:
            break
        }
        
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strDate = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func donePicker() {
        activeTextField!.resignFirstResponder()
        
        switch activeTextField! {
        case dateTextField:
            activeTextField?.text = strDate
        case incomeTextField:
            activeTextField?.text = selectedData
        default:
            break
        }
    }
    
    func cancelPicker() {
        activeTextField!.resignFirstResponder()
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedData = pickerData[row]
    }
    
}
