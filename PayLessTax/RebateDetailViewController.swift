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

    var userRebateCategories = [UserRebateCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rebateCategories ()
    }
    
    
    func rebateCategories(){
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!)
        rebateRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let category = UserRebateCategory(snapshot: snapshot){
                guard category.receiptUIDs.count > 0 else {return}
                category.downloadReceiptDetails() {
                    self.tableView.reloadData()
                    self.calcTotal()
                }
                self.userRebateCategories.append(category)
            }
        })
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RebateDetailCell")!
        
        let category = userRebateCategories[indexPath.section]
        
        let receipt = category.receipts[indexPath.row]
        
        cell.textLabel?.text = "Receipt No: \(receipt.receiptNo)"
        cell.detailTextLabel?.text = "RM \(receipt.amount.asCurrency)"
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return userRebateCategories.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let selectedCategory = userRebateCategories[section]
        let title = selectedCategory.categoryName
        return title
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = userRebateCategories[section]
        return category.receipts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("EditRebateController") as! EditRebateViewController
        vc.preferredContentSize = CGSizeMake(400, 500)
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        let popover = navController.popoverPresentationController
        
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        
        popover?.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 100)
        popover?.delegate = self
        popover?.sourceView = cell.textLabel
        popover?.sourceRect = CGRectMake(0, 20, 0, 0)
        
        self.presentViewController(navController, animated: true, completion: nil)
        
        let category = userRebateCategories[indexPath.section]
        let receipt = category.receipts[indexPath.row]
        vc.rebReceipt = receipt
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let category = userRebateCategories[indexPath.section]
        let receipt = category.receipts[indexPath.row]
        print(category.receipts.count)
        category.receipts.removeAtIndex(indexPath.row)
        print(category.receipts.count)
        
        deleteReceipt(receipt.key, category: receipt.category, completion: {
            self.tableView.reloadData()
        })
        
    }
    
    
    func deleteReceipt(key: String, category: String, completion: () -> Void) {
        self.updateSubtotal(key, category: category)
        
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!).child(category).child("receiptID").child(key)
        rebateRef.removeValue()
        
        let receiptRef = firebaseRef.child("receipt").child(key)
        receiptRef.removeValue()
        completion()
        
    }
    
    func updateSubtotal(key: String, category: String) {
        self.getReceipt(key) { (receipt) in
            let amountDiff = receipt.amount
            let rebateRef = self.firebaseRef.child("rebate").child(User.currentUserId()!).child(category)
            rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
                if var rebateTypeDict = snapshot.value as? [String: AnyObject] {
                    if let oldValue = rebateTypeDict["subtotal"] as? Double {
                        rebateTypeDict["subtotal"] = oldValue - amountDiff
                    }
                    rebateRef.updateChildValues(rebateTypeDict)
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
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        self.userRebateCategories.removeAll()
        rebateCategories ()
        self.tableView.reloadData()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    func calcTotal() {
        var total = 0.0
        for c in userRebateCategories{
            total += c.subTotal
        }
        self.totalLabel.text = "\(total.asCurrency)"
    }
    
}


