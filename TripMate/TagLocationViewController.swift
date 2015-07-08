//
//  TagLocationViewController.swift
//  TripMate
//
//  Created by Rao on 7/7/15.
//  Copyright (c) 2015 Rao. All rights reserved.
//

import UIKit

class TagLocationViewController: UIViewController {
    // Outlets
    @IBOutlet weak var locationTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // RoundedRect border around locationTextView
        self.locationTextView.layer.borderWidth = 5.0
        self.locationTextView.layer.borderColor = UIColor.grayColor().CGColor
        self.locationTextView.layer.cornerRadius = 8

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
