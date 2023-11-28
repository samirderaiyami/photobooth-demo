//
//  ViewController.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 15/11/23.
//

import UIKit

class YourPhotoVC: UIViewController {
    
    @IBOutlet weak var centerImage: UIImageView!

    @IBOutlet weak var viewCenter: UIView!

    var finalImage: UIImage?
    var layout: Layout?

    override func viewDidLoad() {
        centerImage.image = finalImage
        
        NotificationCenter.default.post(name: Notification.Name("UpdateHome"), object: nil, userInfo: nil)

    }
    
    @IBAction func btnCamera(sender: UIButton) {
        if sender.tag == 1 {
            
        } else if sender.tag == 2 {
            
        } else if sender.tag == 3 {
            
        } else if sender.tag == 4 {
            
        }
        
        // image to share
        let image = self.finalImage
        
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
