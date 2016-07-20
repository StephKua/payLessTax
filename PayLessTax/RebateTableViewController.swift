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
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.listOfRebates.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("rebatecell", forIndexPath: indexPath) as! RebateTableViewCell
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
        let rebateRef = firebaseRef.child("Rebate").child(User.useruid())
        rebateRef.observeEventType(.ChildAdded, withBlock:  { (snapshot) in
                if let rebate = Rebate(snapshot: snapshot) {
                    self.listOfRebates.append(rebate)
                }
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject){
        let dest = segue.destinationViewController as! NewRebateViewController
        let indexPath = self.tableView.indexPathForSelectedRow
        let rebate = self.listOfRebates[(indexPath?.row)!]
        dest.selectedRebate = rebate
    }
}

