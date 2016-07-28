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
    
    var bookTotal: Int?
    var donationTotal: Int?
    var sportTotal: Int?
    var total: Int?
    
    var allReceipts = [Receipt]()
    var allAmounts = [Int]()
    
    var rebateType =  ["Books", "Donations", "Sports"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getReceipts()
//        self.calcTotal()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.calcTotal()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RebateDetailCell")!
        
        switch indexPath.section {
        case 0:
            let selectedReceipt = self.bookReceipt[indexPath.row]
            cell.textLabel?.text = "Receipt No: \(selectedReceipt.receiptNo)"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 1:
            let selectedReceipt = self.donationReceipt[indexPath.row]
            cell.textLabel?.text = "Receipt No: \(selectedReceipt.receiptNo)"
            cell.detailTextLabel?.text = "RM \(selectedReceipt.amount)"
        case 2:
            let selectedReceipt = self.sportReceipt[indexPath.row]
            cell.textLabel?.text = "Receipt No: \(selectedReceipt.receiptNo)"
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
            
        case 1:
            let selectedReceipt: Receipt?
            selectedReceipt = self.donationReceipt[indexPath.row]
            vc.rebReceipt = selectedReceipt
            
        case 2:
            let selectedReceipt: Receipt?
            selectedReceipt = self.sportReceipt[indexPath.row]
            vc.rebReceipt = selectedReceipt
            
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
                                switch receipt.category {
                                case self.rebateType[0]:
                                    let previousReceipts = self.bookReceipt.filter({ $0.key == receipt.key })
                                    if let previousReceipt = previousReceipts.first{
                                        if let index = self.bookReceipt.indexOf(previousReceipt){
                                            self.bookReceipt.removeAtIndex(index)
                                            self.bookReceipt.insert(receipt, atIndex: index)
                                        }
                                    }else{
                                        self.bookReceipt.append(receipt)
                                    }
                                case self.rebateType[1]:
                                    let previousReceipts = self.donationReceipt.filter({ $0.key == receipt.key })
                                    if let previousReceipt = previousReceipts.first{
                                        if let index = self.donationReceipt.indexOf(previousReceipt){
                                            self.donationReceipt.removeAtIndex(index)
                                            self.donationReceipt.insert(receipt, atIndex: index)
                                        }
                                    }else{
                                        self.donationReceipt.append(receipt)
                                    }
                                    
                                case self.rebateType[2]:
                                    let previousReceipts = self.sportReceipt.filter({ $0.key == receipt.key })
                                    if let previousReceipt = previousReceipts.first{
                                        if let index = self.sportReceipt.indexOf(previousReceipt){
                                            self.sportReceipt.removeAtIndex(index)
                                            self.sportReceipt.insert(receipt, atIndex: index)
                                        }
                                    }else{
                                        self.sportReceipt.append(receipt)
                                    }
                                default:
                                    break
                                }
//                                self.calcTotal()
                                self.tableView.reloadData()
                                
                            }
                        })
                    }
                }
            })
        }
    }
    
    func calcTotal() {
        for category in rebateType {
            let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(category)
            
            rebateRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                    if let categoryAmount = rebateTypeDict["subtotal"] as? Int {
                        self.allAmounts.removeAll()
                        self.allAmounts.append(categoryAmount)
                    }
                    let total = self.allAmounts.reduce(0, combine: +)
                    self.totalLabel.text = "RM \(total)"
                }
            })
        }
    }
}

/*
 
 switch category {
 case self.rebateType[0]:
 print(self.rebateType[0])
 let book = categoryAmount
 print(book)
 case self.rebateType[2]:
 print(self.rebateType[2])
 let sports = categoryAmount
 print(sports)
 default:
 break
 }
 
 */






//if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
//    if let categoryAmount = rebateTypeDict["subtotal"] as? Int {
//        self.allAmounts.append(categoryAmount)
//        print(self.allAmounts)
//    }
//    let total = self.allAmounts.reduce(0, combine: +)
//    print(total)
//    self.totalLabel.text = "RM \(total)"
//}


//func calcTotal() {
//    for category in rebateType {
//        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(category)
//
//        rebateRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//            if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
//                if let categoryAmount = rebateTypeDict["subtotal"] as? Int {
//                    switch category {
//                    case self.rebateType[0]:
//                        if categoryAmount == 0 {
//                            self.bookTotal = 0
//                        } else {
//                            self.bookTotal = categoryAmount
//                        }
//
//                    case self.rebateType[1]:
//
//                        self.donationTotal = categoryAmount
//
//                    case self.rebateType[2]:
//                        self.sportTotal = categoryAmount
//
//                    default:
//                        break
//                    }
//
//                    guard let book = self.bookTotal, let sport = self.sportTotal, let donation = self.donationTotal else { return }
//
//                    self.total = book + donation + sport
//                    print(self.total)
//                }
//            }
//        })
//    }
//}