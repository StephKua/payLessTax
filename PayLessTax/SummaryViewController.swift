//
//  SummaryViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import UIKit
import Firebase

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var firebaseRef = FIRDatabase.database().reference()
    var income: Income?
    var rebate: Rebate?
    let incomeType = ["Employment", "Rental", "Others"]
    let sections = ["Income", "Deductions"]
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var deductionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var userRebateCategories = [UserRebateCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Summary"
        tableView.allowsSelection = false
        
//        getIncome()
//        rebateCategories()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        getIncome()
        self.userRebateCategories.removeAll()
        rebateCategories()
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
    
    func calcTotal() {
        var total = 0.0
        for c in userRebateCategories{
            total += c.subTotal
        }
        self.deductionsLabel.text = "RM \(total.asCurrency)"
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Income"
        case 1:
            return "Rebates"
        default:
            return ""
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.incomeType.count
        case 1:
            return self.userRebateCategories.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = self.incomeType[indexPath.row]
        case 1:
            let category = userRebateCategories[indexPath.row]
            cell.textLabel?.text = category.categoryName
        default:
            cell.textLabel?.text = ""
        }
        
        switch indexPath.section {
        case 0:
            switch (cell.textLabel!.text)! {
            case "Employment":
                let employment = income?.employmentSubTotal ?? 0
                cell.detailTextLabel?.text = "RM \(employment.asCurrency)"
            case "Rental":
                let rental = income?.rentalSubTotal ?? 0
                cell.detailTextLabel?.text = "RM \(rental.asCurrency)"
            case "Others":
                let others = income?.othersSubTotal ?? 0
                cell.detailTextLabel?.text = "RM \(others.asCurrency)"
            default:
                cell.detailTextLabel?.text = "-"
            }
            
        case 1:
            let category = userRebateCategories[indexPath.row]
            cell.detailTextLabel?.text = "RM \(category.subTotal.asCurrency)"
            
        default:
            break
        }
        
        return cell
    }
    
    
    func getIncome() {
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!)
        incomeRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let income = Income(snapshot: snapshot) {
                self.income = income
                self.tableView.reloadData()
                self.incomeLabel.text = "RM \((income.employmentSubTotal + income.rentalSubTotal + income.othersSubTotal).asCurrency)"
            }
        })
        
    }
    
}
