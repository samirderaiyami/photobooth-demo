//
//  LayoutListVC.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 21/11/23.
//

import UIKit
import DevicePpi


class SavedPhotosVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var arrImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "LayoutCollCell", bundle: nil), forCellWithReuseIdentifier: "LayoutCollCell")
        if let image = loadImage(nameOfImage: "samir_1.jpg") {
            arrImages.append(image)
        }
        collectionView.reloadData()
    }
    
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func loadImage(nameOfImage : String) -> UIImage? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            
            if FileManager.default.fileExists(atPath: imageURL.path) {
                let image    = UIImage(contentsOfFile: imageURL.path)
                return image!
            } else {
                print("File not exists")
                return nil
            }
        }
        
        return nil
    }

    


}

extension SavedPhotosVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayoutCollCell", for: indexPath) as! LayoutCollCell
        let obj = arrImages[indexPath.row]
        cell.imgLayout.image = obj
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90.0, height: 108.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DesignPhotoBoothVC") as! DesignPhotoBoothVC
//        vc.delegate = self
//        if collectionView == collSavedLayouts {
//            vc.layout = Layout.getUserEditedVideos()[indexPath.row]
//        } else {
//            vc.layout = arrLayouts[indexPath.row]
//        }
//        self.navigationController?.pushViewController(vc, animated: true)
    }


}
