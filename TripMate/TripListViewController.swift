//
//  TripListViewController.swift
//  TripMate
//
//  Created by Rao on 7/7/15.
//  Copyright (c) 2015 Rao. All rights reserved.
//

import UIKit

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tripListTableView: UITableView!
    var tripMgr: TripsManager = TripsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripListTableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        tripListTableView.dataSource = self    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAddTripViewController(segue: UIStoryboardSegue) {
        
    }
    @IBAction func confirmAddTrip(segue: UIStoryboardSegue) {
        if let newTripVc = segue.sourceViewController as? NewTripViewController {
            let tripName = newTripVc.tripNameTextField.text
            // TODO(Rao): Check for not empty
            if !tripName.isEmpty {
                tripMgr.addTrip(tripName)
                println("Added new trip: \(tripName)")
                tripListTableView.reloadData()
            }
        }
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "TripSegue" {
            let cell = sender as! UITableViewCell
            let tripViewCtrlr = segue.destinationViewController as! TripViewController
            tripViewCtrlr.trip = tripMgr.getTrip(tripListTableView.indexPathForCell(cell)!.row)
        }
    }

    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        let sz = tripMgr.getTripListSize();
        println("Returning size: \(sz)")
        return tripMgr.getTripListSize()
    }
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripInfoCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = tripMgr.getTripInfo(indexPath.row).name
        //        cell.detailTextLabel.text = "Subtitle #\(indexPath.row)"
        println(cell.frame)
        
        return cell
    }    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}
