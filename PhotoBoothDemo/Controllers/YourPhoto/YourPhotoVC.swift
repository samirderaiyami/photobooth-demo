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
        if let finalImage = finalImage {
            centerImage.image = finalImage
            deleteBackgroundImageIfExists(fileNameToDelete: "layout_\(layout?.id ?? 0)_final.jpg")
            saveImageToDocumentDirectory(image: finalImage)
        }
        
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

extension YourPhotoVC {
    
    private func deleteBackgroundImageIfExists(fileNameToDelete: String){
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if (fileName.lowercased() == fileNameToDelete.lowercased())
                    {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache after deleting images: \(files)")
            }
            
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }

    
    func saveImageToDocumentDirectory(image: UIImage ) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "layout_\(layout?.id ?? 0)_final.jpg" // name of the image to be saved
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
}
