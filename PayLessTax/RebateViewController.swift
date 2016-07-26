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
    
    var rebate: Rebate?
    
    let firebaseRef = FIRDatabase.database().reference()
    var listOfImages = [UIImage]()
    var typesOfRebates = [String]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Get Rebates"
        
        self.typesOfRebates = ["Books", "Donations", "Sports"]
        if let image1 = UIImage(named: "books"), let image2 = UIImage(named: "donation"), let image3 = UIImage(named: "sports"){
            self.listOfImages += [image1, image2, image3]
        }
        self.getRebate()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getRebate()
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
            
            let books = self.rebate?.booksSubTotal ?? 0
            cell.pointLabel.text = "RM \(books)"
            
        case "Donations":
            cell.maxPointLabel.text = "/ RM 1000"
            
            let donations = self.rebate?.donationsSubTotal ?? 0
            cell.pointLabel.text = "RM \(donations)"
            
        case "Sports":
            cell.maxPointLabel.text = "/ RM 1000"
            
            let sports = self.rebate?.sportsSubTotal ?? 0
            cell.pointLabel.text = "RM \(sports)"
            
        default:
            break
        }
        cell.rebateImageView.image = self.listOfImages[indexPath.row]
        
        return cell
    }
    
    
    @IBAction func logOutBtnClicked(sender: UIBarButtonItem) {
        
        try!FIRAuth.auth()?.signOut()
        User.removeUserUid()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navigationController = storyboard.instantiateViewControllerWithIdentifier("RootNavigationController") as? UINavigationController{
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    
    func getRebate() {
        let rebateRef = firebaseRef.child("rebate").child(User.currentUserId()!)
        rebateRef.observeEventType(.Value, withBlock:  { (snapshot) in
            if let rebate = Rebate(snapshot: snapshot) {
                self.rebate = rebate
                self.tableView.reloadData()
            }
        })
        
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
