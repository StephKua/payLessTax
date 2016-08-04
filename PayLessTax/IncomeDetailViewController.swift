//
//  IncomeDetailViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 25/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class IncomeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    var firebaseRef = FIRDatabase.database().reference()
    
    var employmentInc = [Receipt]()
    var rentalInc = [Receipt]()
    var otherInc = [Receipt]()

    var incomeType = ["Employment", "Rental", "Others"]
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getIncome()
        self.calcTotal { (x, y, z) in
            self.totalLabel.text = "RM \(x + y + z)"
        }
    }
    
    //    override func viewWillAppear(animated: Bool) {
    //        super.viewWillAppear(true)
    //        self.calcTotal()
    //    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IncomeDetailCell")!
        
        switch indexPath.section {
        case 0:
            let selectedReceipt = self.employmentInc[indexPath.row]
            cell.textLabel?.text = "Ref. No: \(selectedReceipt.refNo)"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 1:
            let selectedReceipt = self.rentalInc[indexPath.row]
            cell.textLabel?.text = "Ref. No: \(selectedReceipt.refNo)"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 2:
            let selectedReceipt = self.otherInc[indexPath.row]
            cell.textLabel?.text = "Ref. No: \(selectedReceipt.refNo)"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        default:
            cell.textLabel?.text = "No income"
            cell.detailTextLabel?.text = "RM 0"
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return incomeType.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.employmentInc.count
        case 1:
            return self.rentalInc.count
        case 2:
            return self.otherInc.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.incomeType[0]
        case 1:
            return self.incomeType[1]
        case 2:
            return self.incomeType[2]
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("EditIncController") as! EditIncViewController
        vc.preferredContentSize = CGSizeMake(400, 300)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        let popover = navController.popoverPresentationController
        let section = tableView.indexPathForSelectedRow?.section
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 100)
        popover?.delegate = self
        popover?.sourceView = cell.textLabel
        popover?.sourceRect = CGRectMake(0, 20, 0, 0)
        
        self.presentViewController(navController, animated: true, completion: nil)
        
        switch section! {
        case 0:
            let selectedReceipt: Receipt?
            selectedReceipt = self.employmentInc[indexPath.row]
            vc.incReceipt = selectedReceipt
            print(selectedReceipt!.amount)
            print("receipt \(selectedReceipt)")
            
        case 1:
            let selectedReceipt: Receipt?
            selectedReceipt = self.rentalInc[indexPath.row]
            vc.incReceipt = selectedReceipt
            print(selectedReceipt!.amount)
            
        case 2:
            let selectedReceipt: Receipt?
            selectedReceipt = self.otherInc[indexPath.row]
            vc.incReceipt = selectedReceipt
            print(selectedReceipt!.amount)
            
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            let selectedReceipt = self.employmentInc[indexPath.row]
            self.deleteReceipt(selectedReceipt.key, category: selectedReceipt.category)
            self.employmentInc.removeAtIndex(indexPath.row)
            
        case 1:
            let selectedReceipt = self.rentalInc[indexPath.row]
            self.deleteReceipt(selectedReceipt.key, category: selectedReceipt.category)
            self.rentalInc.removeAtIndex(indexPath.row)
            
        case 2:
            let selectedReceipt = self.otherInc[indexPath.row]
            self.deleteReceipt(selectedReceipt.key, category: selectedReceipt.category)
            self.otherInc.removeAtIndex(indexPath.row)
            
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    
    func deleteReceipt(key: String, category: String) {
        self.updateSubtotal(key, category: category)
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(category).child("receiptID").child(key)
        incomeRef.removeValue()
        
        let receiptRef = firebaseRef.child("receipt").child(key)
        receiptRef.removeValue()
        
    }
    
    func updateSubtotal(key: String, category: String) {
        self.getReceipt(key) { (receipt) in
            let amountDiff = receipt.amount
            let incomeRef = self.firebaseRef.child("income").child(User.currentUserId()!).child(category)
            incomeRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
                if var incomeTypeDict = snapshot.value as? [String: AnyObject] {
                    if let oldValue = incomeTypeDict["subtotal"] as? Int {
                        incomeTypeDict["subtotal"] = oldValue - amountDiff
                    }
                    incomeRef.updateChildValues(incomeTypeDict)
                }
            })
        }
    }
    
    func getReceipt(key: String, completionHandler: (receipt: Receipt) -> ()){
        let receiptRef = firebaseRef.child("receipt").child(key)
        receiptRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let receipt = Receipt(snapshot: snapshot) {
                completionHandler(receipt: receipt)
            }
        })
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func getIncome() {
        for category in incomeType {
            let incomeRef = firebaseRef.child("income").child(User.currentUserId()!).child(category).child("receiptID")
            incomeRef.observeEventType(.Value, withBlock: { (snapshot) in
                if let incomeDict = snapshot.value as? [String: Bool] {
                    for (key, _) in incomeDict {
                        let receiptRef = self.firebaseRef.child("receipt").child(key)
                        receiptRef.observeEventType(.Value, withBlock: { (receiptSnapshot) in
                            if let receipt = Receipt(snapshot: receiptSnapshot) {
                                switch receipt.category {
                                case self.incomeType[0]:
                                    let previousReceipts = self.employmentInc.filter({ $0.key == receipt.key})
                                    if let previousReceipt = previousReceipts.first {
                                        if let index = self.employmentInc.indexOf(previousReceipt) {
                                            self.employmentInc.removeAtIndex(index)
                                            self.employmentInc.insert(receipt, atIndex: index)
                                        }
                                    } else {
                                        self.employmentInc.append(receipt)
                                    }
                                    
                                case self.incomeType[1]:
                                    let previousReceipts = self.rentalInc.filter({ $0.key == receipt.key})
                                    if let previousReceipt = previousReceipts.first {
                                        if let index = self.rentalInc.indexOf(previousReceipt) {
                                            self.rentalInc.removeAtIndex(index)
                                            self.rentalInc.insert(receipt, atIndex: index)
                                        }
                                    } else {
                                        self.rentalInc.append(receipt)
                                    }
                                    
                                case self.incomeType[2]:
                                    let previousReceipts = self.otherInc.filter({ $0.key == receipt.key})
                                    if let previousReceipt = previousReceipts.first {
                                        if let index = self.otherInc.indexOf(previousReceipt) {
                                            self.otherInc.removeAtIndex(index)
                                            self.otherInc.insert(receipt, atIndex: index)
                                        }
                                    } else {
                                        self.otherInc.append(receipt)
                                    }
                                default:
                                    break
                                }
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            })
        }
    }
    
    func calcTotal(completionHandler: (x: Int, y: Int, z: Int) -> ()) {
        var employment: Int = 0
        var rental: Int = 0
        var other: Int = 0
        
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!)
        for category in incomeType {
            incomeRef.child(category).observeEventType(.Value, withBlock: { (snapshot) in
                if var incomeTypeDict = snapshot.value as? [String: AnyObject] {
                    if let categoryAmount = incomeTypeDict ["subtotal"] as? Int {
                        switch category {
                        case self.incomeType[0]:
                            employment = categoryAmount
                        case self.incomeType[1]:
                            rental = categoryAmount
                        case self.incomeType[2]:
                            other = categoryAmount
                        default:
                            break
                        }
                        completionHandler(x: employment, y: rental, z: other)
                    }
                    
                }
            })
        }
    }
    
}
