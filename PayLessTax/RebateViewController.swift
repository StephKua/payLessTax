//
//  RebateTableViewController.swift
//  PayLessTax
//
//  Created by Sheena Moh on 19/07/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//



import UIKit
import Firebase

class RebateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listOfPoints = [String]()
    let firebaseRef = FIRDatabase.database().reference()
    var listOfImages = [UIImage]()
    var typesOfRebates = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Get Rebates"
        getRebate()
        self.typesOfRebates = ["Books", "Donations", "Sports"]
        if let image1 = UIImage(named: "books"), let image2 = UIImage(named: "donation"), let image3 = UIImage(named: "sports"){
            self.listOfImages += [image1, image2, image3]
        }
        self.tableView.reloadData()
        
        
        print(self.typesOfRebates)
        print(self.listOfImages)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.typesOfRebates.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RebateCell", forIndexPath: indexPath) as! RebateTableViewCell
        cell.rebateLabel.text = self.typesOfRebates[indexPath.row]
        
        switch cell.rebateLabel.text! {
        case "Books":
            cell.maxPointLabel.text = "/ RM 1000"
        case "Donations":
            cell.maxPointLabel.text = "/ RM 1000"
        case "Sports":
            cell.maxPointLabel.text = "/ RM 1000"
        default:
            break
        }
        if self.listOfPoints.count == 0 {
            cell.pointLabel.text = "RM 0"
        } else {
            cell.pointLabel.text = "RM \(self.listOfPoints[indexPath.row])"
        }
        //        let rebate = self.listOfRebates[indexPath.row]
        //        rebate.rebateName = self.typesOfRebates[indexPath.row]
        //        cell.rebateLabel.text = self.typesOfRebates[indexPath.row]
        //        cell.pointLabel.text = "RM \(rebate.rebatePoints)"
        //        cell.maxPointLabel.text = "RM \(rebate.rebateMaxPoints)"
        cell.rebateImageView.image = self.listOfImages[indexPath.row]
        return cell
    }
    
    
    @IBAction func logOutBtnClicked(sender: UIBarButtonItem) {
        try! FIRAuth.auth()!.signOut()
        // User.removeUserUid()
    }
    
    func getRebate() {
        for i in 0..<self.typesOfRebates.count {
        let rebateRef = firebaseRef.child("Rebate").child(User.currentUserId()!).child(self.typesOfRebates[i])
        rebateRef.observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            if let rebate = Rebate(snapshot: snapshot) {
                self.listOfPoints.append("\(rebate.subTotal)")
            }
        })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewRebateSegue" {
        let dest = segue.destinationViewController as! NewRebateViewController
        let indexPath = self.tableView.indexPathForSelectedRow
        let rebate = self.typesOfRebates[(indexPath!.row)]
        dest.selectedRebate = rebate
        }
    }
    
    
}
