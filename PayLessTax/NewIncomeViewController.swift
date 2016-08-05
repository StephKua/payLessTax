//
//  NewIncomeViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class NewIncomeViewController: CameraViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var lastSubtotal = Double()
    var strDate: String = ""
    var datePicker = UIDatePicker()
    var imageUrl: String?
    var activeTextField: UITextField?
    
    @IBOutlet weak var incomeImage: UIImageView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var incomePickerView = UIPickerView()
    let pickerData = ["Employment", "Rental", "Others"]
    var selectedData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker(frame: CGRectMake(10, 10, view.frame.width, 200))
        incomePickerView = UIPickerView(frame: CGRectMake(10, 10, view.frame.width, 200))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strDate = dateFormatter.stringFromDate(datePicker.date)
        dateTextField.text = strDate
        
    }
    
    override func imageUploadCompleted(imageURL: String, image: UIImage) {
        let rect = CGRectMake(0, 0, 100, 100)
        incomeImage.image = image
        incomeImage.image!.drawInRect(rect)
        self.imageUrl = imageURL
        
    }
    
    @IBAction func addReceipt(sender: UIButton) {
        self.presentViewController(fusuma, animated: true, completion: nil)
    }
    
    @IBAction func onSaveBtnPressed(sender: UIBarButtonItem) {
        if amountTextField.text == "" || self.isNumber(amountTextField.text!) == false {
            self.resignFirstResponder()
            let alertController = UIAlertController(title: "Invalid amount", message: "Please enter a valid amount", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else if incomeTextField.text == "" {
            let alertController = UIAlertController(title: "No Income Type Selected", message: "Please select an income type", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(dismissAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            self.addIncome()
            self.navigationController?.popViewControllerAnimated(true)
            self.resignFirstResponder()
        }
        
    }
    
    func addIncome() {
        guard let date = dateTextField.text, let incomeType = incomeTextField.text, let ref = refTextField.text, let amount = amountTextField.text else { return }
        
        var amountAdded = Double()
        if amount != "" {
            amountAdded = Double(amount)!
        }
        
        let imageLink = self.imageUrl ?? ""
        
        
        let receiptID = NSUUID().UUIDString
        let imageID = NSUUID().UUIDString
        
        let receiptRef = firebaseRef.child("receipt").child(receiptID)
        let receiptDict = ["date": date, "reference no": ref, "amount": amountAdded, "category": incomeType]
        receiptRef.setValue(receiptDict)
        
        let imageRef = firebaseRef.child("image").child(imageID)
        let imageDict = ["imageUrl": imageLink, "userID": User.currentUserId()!]
        imageRef.setValue(imageDict)
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(incomeType)
        
        incomeRef.child("receiptID").child(receiptID).setValue(true)
        incomeRef.child("imageID").child(imageID).setValue(true)
        
        incomeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if var incomeTypeDict = snapshot.value as? [String: AnyObject]{
                if let oldValue = incomeTypeDict["subtotal"] as? Double{
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
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: #selector(NewRebateViewController.donePicker), forControlEvents: UIControlEvents.TouchUpInside)
        
        incomePickerView.backgroundColor = UIColor.clearColor()
        incomePickerView.dataSource = self
        incomePickerView.delegate = self
        incomePickerView.showsSelectionIndicator = true
        self.selectedData = self.pickerData[0]
        
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
        case incomeTextField:
            inputView.addSubview(incomePickerView)
        default:
            break
        }
        
    }
    
    func donePicker() {
        activeTextField!.resignFirstResponder()
        
        switch activeTextField! {
        case dateTextField:
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            strDate = dateFormatter.stringFromDate(datePicker.date)
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
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWasShown), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize!.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var rect = self.view.frame
        rect.size.height -= kbSize!.height
        
        if let activeField = activeTextField {
            if CGRectContainsPoint(rect, activeTextField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
                
            }
        }
    }
    
    override func setInfo(total: String, date: String, InvNo: String) {
        self.amountTextField.text = total
        self.dateTextField.text = date
        self.refTextField.text = InvNo
    }
    
    
}
