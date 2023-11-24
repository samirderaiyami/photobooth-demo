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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "LayoutCollCell", bundle: nil), forCellWithReuseIdentifier: "LayoutCollCell")
        collectionView.reloadData()

    }
    

}

extension LayoutListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        return arrLayouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LayoutCollCell", for: indexPath) as! LayoutCollCell
        cell.imgLayout.image = UIImage(named: arrLayouts[indexPath.row].viewName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        var height = 0.0
        var width = 0.0
        
//        if indexPath.row == 0 {
            height = 108.0
            width = 90.0
//        } else {
//            height = 100.0
//            width = 108.0
//        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DesignPhotoBoothVC") as! DesignPhotoBoothVC
        vc.layout = arrLayouts[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)

    }


}
