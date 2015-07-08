//
//  TripViewController.swift
//  
//
//  Created by Rao on 7/2/15.
//
//

import UIKit
import UIKit
import Photos
import ImagePickerSheetController
import MobileCoreServices

class TripViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Models
    var trip: Trip!
    
    // Outlets
    @IBOutlet weak var entryTableView: UITableView!
    
    // Actions
    @IBAction func cameraSelected(sender: UIBarButtonItem) {
        self.presentImagePickerSheet()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        println("viewdidload: \(trip)")
    }
    
    // MARK: Other Methods
    
    func presentImagePickerSheet() {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentImagePickerSheet()
                }
            }
            
            return
        }
        
        if authorization == .Authorized {
            let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType = source
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    println("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                controller.sourceType = sourceType
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
            
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add comment", comment: "Action Title"), handler: { _ in
                presentImagePickerController(.Camera)
                }, secondaryHandler: { _, numberOfPhotos in
                    println("Comment \(numberOfPhotos) photos")
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
                presentImagePickerController(.PhotoLibrary)
                }, secondaryHandler: { _, numberOfPhotos in
                    controller.getSelectedImagesWithCompletion() { images in
                        println("Send \(images) photos")
                    }
            }))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
                println("Cancelled")
            }))
            
            presentViewController(controller, animated: true, completion: nil)
        }
        else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("ImagePickerSheet needs access to the camera roll", comment: "ImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Tag location related
    @IBAction func cancelTagLocationViewController(segue: UIStoryboardSegue) {
    }
    @IBAction func confirmTagLocationViewController(segue: UIStoryboardSegue) {
        if let tagLocationVc = segue.sourceViewController as? TagLocationViewController {
            let notes = tagLocationVc.locationTextView.text
            // TODO(Rao): Check for not empty
            if !notes.isEmpty {
                var entry = TripEntry()
                entry.text = notes
                trip.addEntry(entry)
                println("Added new trip entry")
                entryTableView.reloadData()
            }
        }
    }
    
    // Table view related
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        let cnt = trip.getEntriesCount()
        println("Returning size: \(cnt)")
        return cnt
    }
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TripEntryCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = trip.getEntry(indexPath.row).text
        //        cell.detailTextLabel.text = "Subtitle #\(indexPath.row)"
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
}
