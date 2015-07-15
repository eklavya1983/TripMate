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

class PhotoEntryCreator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parentCtrlr: UIViewController
    var delegate: PhotoEntryCreatorDelegate?
    
    init(parentCtrlr: UIViewController) {
        self.parentCtrlr = parentCtrlr
    }
    func presentPhotoEntryCreator() {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentPhotoEntryCreator()
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
                
                self.parentCtrlr.presentViewController(controller, animated: true, completion: nil)
            }
            
            let controller = ImagePickerSheetController()
            controller.addAction(ImageAction(
                title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"),
                secondaryTitle: NSLocalizedString("Add comment", comment: "Action Title"),
                handler: { _ in
                    presentImagePickerController(.Camera)
                },
                secondaryHandler: { _, numberOfPhotos in
                    println("Comment \(numberOfPhotos) photos")
                }))
            controller.addAction(ImageAction(
                title: NSLocalizedString("Photo Library", comment: "Action Title"),
                secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String},
                handler: { _ in
                    presentImagePickerController(.PhotoLibrary)
                },
                secondaryHandler: { _, numberOfPhotos in
                    let assets = controller.getSelectedAssets()
                    let tripEntry = TripEntry()
                    tripEntry.images = assets.map { asset in
                        let info = ImageInfo()
                        info.localPath = asset.localIdentifier
                        return info
                    }
                    if (assets.count > 0) {
                        tripEntry.location = assets[0].location
                    }
                    self.delegate?.photoentryCreator(self, createdEntry: tripEntry)
                    println("Send \(assets.count) photos")
                }))
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: { _ in
                println("Cancelled")
            }))
            
            parentCtrlr.presentViewController(controller, animated: true, completion: nil)
        } else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("ImagePickerSheet needs access to the camera roll", comment: "ImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        parentCtrlr.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol PhotoEntryCreatorDelegate {
    func photoentryCreator(creator: PhotoEntryCreator, createdEntry entry: TripEntry)
}

class TripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PhotoEntryCreatorDelegate {
    
    // Models
    var trip: Trip!
    
    // Controls
    var photoEntryCreator: PhotoEntryCreator!
    
    // Outlets
    @IBOutlet weak var entryTableView: UITableView!
    
    // Actions
    @IBAction func cameraSelected(sender: UIBarButtonItem) {
        photoEntryCreator.presentPhotoEntryCreator()
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoEntryCreator = PhotoEntryCreator(parentCtrlr: self)
        photoEntryCreator.delegate = self
        
        // Remove footer
        entryTableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        var longPressGesture = UILongPressGestureRecognizer(target: self, action: "tableViewLongPressed:")
        longPressGesture.minimumPressDuration = 1.0
        entryTableView.addGestureRecognizer(longPressGesture)
        
        println("viewdidload: \(trip)")
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
                addEntry(entry)
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
        let imageManager = PHImageManager.defaultManager()
        let entry = trip.getEntry(indexPath.row)
        let cell = tableView.dequeueReusableCellWithIdentifier("TripEntryCell", forIndexPath: indexPath) as! TripEntryTableViewCell
        cell.infoLabel.text = trip.getEntry(indexPath.row).text
        if entry.images != nil && entry.images!.count > 0  && entry.images![0].localPath != nil {
            let fetchRes = PHAsset.fetchAssetsWithLocalIdentifiers([entry.images![0].localPath!], options: nil)
            fetchRes.enumerateObjectsUsingBlock { (obj, _, _) in
                if let asset = obj as? PHAsset {                    
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .HighQualityFormat
                    imageManager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: options) { image, _ in
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TripEntryTableViewCell {
                            cell.pictureView.image = image
                        }
                    }
                }
            }
        } else {
            cell.pictureView.image = UIImage(named: "travel")
        }
        return cell
    }

    
    func tableViewLongPressed(longPress: UIGestureRecognizer) {
        if longPress.state == UIGestureRecognizerState.Began {
            let point = longPress.locationInView(entryTableView)
            let indexPath = entryTableView.indexPathForRowAtPoint(point)
            if indexPath != nil {
                println("longpressed on: \(indexPath)")
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in}
                let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
                    self.removeEntry(indexPath!)
                }
                alertController.addAction(cancelAction)
                alertController.addAction(deleteAction)
                
                self.presentViewController(alertController, animated: true) {}
            }

        }
    }
    
    // MARK: PhotoEntryCreator related
    func photoentryCreator(creator: PhotoEntryCreator, createdEntry entry: TripEntry) {
        addEntry(entry)
    }
    
    func addEntry(entry: TripEntry) {
        trip.addEntry(entry)
        println("Added new trip entry: \(entry)")
        entryTableView.reloadData()
    }
    
    func removeEntry(indexPath: NSIndexPath) {
        trip.removeEntry(indexPath.row)
        entryTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }

}
