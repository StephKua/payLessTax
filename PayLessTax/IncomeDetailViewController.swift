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
    
    var allIncome = [Receipt]()
    var allAmounts = [Int]()
    
    var incomeType = ["Employment", "Rental", "Others"]
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getIncome()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("IncomeDetailCell")!
        
        switch indexPath.section {
        case 0:
            let selectedReceipt = self.employmentInc[indexPath.row]
            cell.textLabel?.text = "Ref. No: \(selectedReceipt.refNo) (Date: \(selectedReceipt.date))"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 1:
            let selectedReceipt = self.rentalInc[indexPath.row]
            cell.textLabel?.text = "Ref. No: \(selectedReceipt.refNo) (Date: \(selectedReceipt.date))"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 2:
            let selectedReceipt = self.otherInc[indexPath.row]
            cell.textLabel?.text = "Ref. No: \(selectedReceipt.refNo) (Date: \(selectedReceipt.date))"
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
        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.Up
        popover?.delegate = self
        popover?.sourceView = self.tableView
        
        self.presentViewController(navController, animated: true, completion: nil)
        self.performSegueWithIdentifier("EditIncSegue", sender: self)
        
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
                                self.allIncome.append(receipt)
                            }
                            
                            for receipt in self.allIncome {
                                self.allAmounts.append(receipt.amount)
                                self.totalLabel.text = "RM \(self.allAmounts.reduce(0, combine: +))"
                                
                                switch receipt.category {
                                case self.incomeType[0]:
                                    self.employmentInc.removeAll()
                                    self.employmentInc.append(receipt)
                                    
                                case self.incomeType[1]:
                                    self.rentalInc.removeAll()
                                    self.rentalInc.append(receipt)
                                    
                                case self.incomeType[2]:
                                    self.otherInc.removeAll()
                                    self.otherInc.append(receipt)
                                    
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
    
}
