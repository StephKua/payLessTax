//
//  RebateDetailViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 20/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase


class RebateDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var firebaseRef = FIRDatabase.database().reference()
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var bookReceipt = [Receipt]()
    var donationReceipt = [Receipt]()
    var sportReceipt = [Receipt]()
    
    var allReceipts = [Receipt]()
    var allAmounts = [Int]()
    
    var rebateType =  ["Books", "Donations", "Sports"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getReceipts()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RebateDetailCell")!
        
        switch indexPath.section {
        case 0:
            let selectedReceipt = self.bookReceipt[indexPath.row]
            cell.textLabel?.text = "Receipt No: \(selectedReceipt.receiptNo) (Date: \(selectedReceipt.date))"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 1:
            let selectedReceipt = self.donationReceipt[indexPath.row]
            cell.textLabel?.text = "Receipt No: \(selectedReceipt.receiptNo) (Date: \(selectedReceipt.date))"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 2:
            let selectedReceipt = self.sportReceipt[indexPath.row]
            cell.textLabel?.text = "Receipt No: \(selectedReceipt.receiptNo) (Date: \(selectedReceipt.date))"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        default:
            cell.textLabel?.text = "No receipts"
            cell.detailTextLabel?.text = "RM 0"
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rebateType.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return self.rebateType[0]
        case 1:
            return self.rebateType[1]
        case 2:
            return self.rebateType[2]
        default:
            return ""
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            print("bookcount row count: \(self.bookReceipt.count)")
            return self.bookReceipt.count
            
        case 1:
            return self.donationReceipt.count
        case 2:
            return self.sportReceipt.count
        default:
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("EditRebateController") as! EditRebateViewController
        vc.preferredContentSize = CGSizeMake(400, 300)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        let popover = navController.popoverPresentationController
        let section = tableView.indexPathForSelectedRow?.section
        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.Up
        popover?.delegate = self
        popover?.sourceView = self.tableView
        
        self.presentViewController(navController, animated: true, completion: nil)
        self.performSegueWithIdentifier("EditRebSegue", sender: self)
        
        switch section! {
        case 0:
            let selectedReceipt: Receipt?
            selectedReceipt = self.bookReceipt[indexPath.row]
            vc.rebReceipt = selectedReceipt
//            print(selectedReceipt!.amount)
//            print("receipt \(selectedReceipt)")
            
        case 1:
            let selectedReceipt: Receipt?
            selectedReceipt = self.donationReceipt[indexPath.row]
            vc.rebReceipt = selectedReceipt
//            print(selectedReceipt!.amount)
            
        case 2:
            let selectedReceipt: Receipt?
            selectedReceipt = self.sportReceipt[indexPath.row]
            vc.rebReceipt = selectedReceipt
//            print(selectedReceipt!.amount)
            
        default:
            break
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    func getReceipts() {
        for category in rebateType {
            let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(category).child("receiptID")
            rebateRef.observeEventType(.Value, withBlock: { (snapshot) in
                if let rebateDict = snapshot.value as? [String: Bool] {
                    for (key, _) in rebateDict {
                        let receiptRef = self.firebaseRef.child("receipt").child(key)
                        receiptRef.observeEventType(.Value, withBlock: { (receiptSnapshot) in
                            if let receipt = Receipt(snapshot: receiptSnapshot) {
                                print("amount: \(receipt.amount)")
                                self.allReceipts.removeAll()
                                self.allReceipts.append(receipt)
                                
                                print("receipt: \(self.allReceipts)")
                                print("receipt count \(self.allReceipts.count)")
                            }
                            
                            for receipt in self.allReceipts {
//                                self.allAmounts.append(receipt.amount)
//                                self.totalLabel.text = "RM \(self.allAmounts.reduce(0, combine: +))"
                                
                                switch receipt.category {
                                case self.rebateType[0]:
//                                    self.bookReceipt.removeAll()
                                    self.bookReceipt.append(receipt)
                                    print("bookcount: \(self.bookReceipt.count)")
                                case self.rebateType[1]:
//                                    self.donationReceipt.removeAll()
                                    self.donationReceipt.append(receipt)
                                case self.rebateType[2]:
//                                    self.sportReceipt.removeAll()
                                    self.sportReceipt.append(receipt)
                                    print("sportscount: \(self.sportReceipt.count)")
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
