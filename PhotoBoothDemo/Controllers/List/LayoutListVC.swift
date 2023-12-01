//
//  LayoutListVC.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 21/11/23.
//

import UIKit
import DevicePpi


class LayoutListVC: UIViewController {
    
    
    let ppi: Double = {
        switch Ppi.get() {
        case .success(let ppi):
            return ppi
        case .unknown(let bestGuessPpi, let error):
            // A bestGuessPpi value is provided but may be incorrect
            // Treat as a non-fatal error -- e.g. log to your backend and/or display a message
            return bestGuessPpi
        }
    }()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collSavedLayouts: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "LayoutCollCell", bundle: nil), forCellWithReuseIdentifier: "LayoutCollCell")
        collSavedLayouts.register(UINib(nibName: "LayoutCollCell", bundle: nil), forCellWithReuseIdentifier: "LayoutCollCell")
        collectionView.reloadData()
        collSavedLayouts.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("UpdateHome"), object: nil)

    }
    
    @objc func methodOfReceivedNotification(notification: Notification) {
        self.collSavedLayouts.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("UpdateHome"), object: nil)
    }
    
    
    @IBAction func btnFinalImages(sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedPhotosVC") as! SavedPhotosVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension LayoutListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        if collectionView == collSavedLayouts {
            return Layout.getUserEditedVideos().count
        }
        return arrLayouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if collectionView == collSavedLayouts {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayoutCollCell", for: indexPath) as! LayoutCollCell
            let obj = Layout.getUserEditedVideos()[indexPath.row]
            
            if let prevImageData = obj.previewImage {
                cell.imgLayout.image = UIImage(data: prevImageData)
            } else {
                cell.imgLayout.image = UIImage(named: obj.viewName)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayoutCollCell", for: indexPath) as! LayoutCollCell
            cell.imgLayout.image = UIImage(named: arrLayouts[indexPath.row].viewName)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90.0, height: 108.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DesignPhotoBoothVC") as! DesignPhotoBoothVC
        vc.delegate = self
        if collectionView == collSavedLayouts {
            vc.layout = Layout.getUserEditedVideos()[indexPath.row]
        } else {
            vc.layout = arrLayouts[indexPath.row]
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }


}

extension LayoutListVC: DesignPhotoBoothVCDelegate {
    func updateListUI() {
        self.collSavedLayouts.reloadData()
    }
}
