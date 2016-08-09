//
//  RebateTableViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//


import UIKit
import Firebase
import SDWebImage

class RebateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rebate: Rebate?
    
    let firebaseRef = FIRDatabase.database().reference()
    
    var rebateCat = [RebateCategories]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.rebateCat.removeAll()
        self.title = "Get Rebates"
        self.getRebateCategories()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rebateCat.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RebateCell", forIndexPath: indexPath) as! RebateTableViewCell
        
        let selectedItems = self.rebateCat[indexPath.row]
        
        cell.rebateLabel.text = selectedItems.title
        cell.pointLabel.text = "RM \(selectedItems.subtotal.asCurrencyNoDecimal)"
        cell.maxPointLabel.text = "/ RM \(selectedItems.max)"
        
        cell.rebateImageView.layer.cornerRadius = cell.rebateImageView.frame.size.width / 2
        cell.rebateImageView.clipsToBounds = true
        
        let url = NSURL(string: selectedItems.imageUrl)
        cell.rebateImageView.sd_setImageWithURL(url)
        
        
        return cell
    }
    
    func getRebateCategories() {
        let rebateCatRef = firebaseRef.child("RebateCategories")
        rebateCatRef.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            if let rebateCat = RebateCategories(snapshot: snapshot) {
                self.rebateCat.append(rebateCat)
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func logOutBtnClicked(sender: UIBarButtonItem) {
        
        try!FIRAuth.auth()?.signOut()
        User.removeUserUid()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationController = storyboard.instantiateViewControllerWithIdentifier("RootNavigationController") as? UINavigationController{
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewRebateSegue" {
            let dest = segue.destinationViewController as! NewRebateViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let rebate = self.rebateCat[(indexPath!.row)]
            dest.selectedRebate = rebate
        }
    }
}


extension Double {
    var asCurrencyNoDecimal:String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyAccountingStyle
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        return formatter.stringFromNumber(self)!
    }
    
    var asCurrency:String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyAccountingStyle
        formatter.currencySymbol = ""
        return formatter.stringFromNumber(self)!
    }
}

extension String {
    var isValidNumber:Bool {
        let amount = self
        let amountClean = amount.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let nonDigits = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let isValidNumber : Bool = amountClean.rangeOfCharacterFromSet(nonDigits) == nil
        return isValidNumber
    }
    
    var formattedNo: String {
        let str = self
        let formatter = str.stringByReplacingOccurrencesOfString(",", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return formatter
    }
}



