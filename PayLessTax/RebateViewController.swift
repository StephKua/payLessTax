//
//  RebateTableViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//



import UIKit
import Firebase

class RebateTableViewController: UITableViewController {
    
    var listOfRebates = [Rebate]()
    let firebaseRef = FIRDatabase.database().reference()
    var listOfImages = [UIImage]()
    var typesOfRebates = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Get Rebates"
        getRebate()
        self.typesOfRebates = ["Books", "Donations", "Sports"]
        self.tableView.reloadData()
        
        if let image1 = UIImage(named: "books"), let image2 = UIImage(named: "donation"), let image3 = UIImage(named: "sports"){
            self.listOfImages += [image1, image2, image3]
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.listOfRebates.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RebateCell", forIndexPath: indexPath) as! RebateTableViewCell
        let rebate = self.listOfRebates[indexPath.row]
        rebate.rebateName = self.typesOfRebates[indexPath.row]
        cell.rebateLabel.text = self.typesOfRebates[indexPath.row]
        cell.pointLabel.text = "RM \(rebate.rebatePoints)"
        cell.maxPointLabel.text = "RM \(rebate.rebateMaxPoints)"
        cell.rebateImageView.image = self.listOfImages[indexPath.row]
        return cell
    }
    
    
    @IBAction func logOutBtnClicked(sender: UIBarButtonItem) {
        try! FIRAuth.auth()!.signOut()
        // User.removeUserUid()
    }
    
    func getRebate() {
        let rebateRef = firebaseRef.child("Rebate").child(User.currentUserId()!)
        rebateRef.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
            if let rebate = Rebate(snapshot: snapshot) {
                self.listOfRebates.append(rebate)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! NewRebateViewController
        let indexPath = self.tableView.indexPathForSelectedRow
        let rebate = self.listOfRebates[(indexPath!.row)]
        dest.selectedRebate = rebate
    }
    
//    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject){
//        let dest = segue.destinationViewController as! NewRebateViewController
//        let indexPath = self.tableView.indexPathForSelectedRow
//        let rebate = self.listOfRebates[(indexPath?.row)!]
//        dest.selectedRebate = rebate
//    }
}
