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
    
    var sections: [Section] = SectionsData().getSectionsFromData()
    var firebaseRef = FIRDatabase.database().reference()
    var income: Income?
    var rebate: Rebate?
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var deductionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Summary for the Year"
        getIncome()
        getRebates()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].heading
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        
        switch (cell.textLabel!.text)! {
        case "Employment":
            let employment = income?.employmentSubTotal ?? 0
            cell.detailTextLabel?.text = "RM \(employment)"
        case "Rental":
            let rental = income?.rentalSubTotal ?? 0
            cell.detailTextLabel?.text = "RM \(rental)"
        case "Others":
            let others = income?.othersSubTotal ?? 0
            cell.detailTextLabel?.text = "RM \(others)"
            
        case "Books":
            let books = rebate?.booksSubTotal ?? 0
            cell.detailTextLabel?.text = "RM \(books)"
        case "Donations":
            let donations = rebate?.donationsSubTotal ?? 0
            cell.detailTextLabel?.text = "RM \(donations)"
        case "Sports":
            let sports = rebate?.sportsSubTotal ?? 0
            cell.detailTextLabel?.text = "RM \(sports)"

        default:
            cell.detailTextLabel?.text = "-"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print(sections[indexPath.section].items[indexPath.row])
    }
    
    func getIncome() {
        let incomeRef = firebaseRef.child("income").child(User.currentUserId()!)
        incomeRef.observeEventType(.Value, withBlock: { (snapshot) in
            if let income = Income(snapshot: snapshot) {
                self.income = income
                self.tableView.reloadData()
                
                self.incomeLabel.text = "RM \(income.employmentSubTotal + income.rentalSubTotal + income.othersSubTotal)"
            }
        })
        
    }
    
    func getRebates() {
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!)
        rebateRef.observeEventType(.Value, withBlock:{ (snapshot) in
            if let rebate = Rebate(snapshot: snapshot) {
                self.rebate = rebate
                self.tableView.reloadData()
                
                self.deductionsLabel.text = "RM \(rebate.booksSubTotal + rebate.donationsSubTotal + rebate.sportsSubTotal)"
            }
        })
        
    }
    
}
