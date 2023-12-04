//
//  LayoutListVC.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 21/11/23.
//

import UIKit


class SavedPhotosVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "LayoutCollCell", bundle: nil), forCellWithReuseIdentifier: "LayoutCollCell")
        loadImage()
        collectionView.reloadData()
    }
    
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func loadImage()  {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            let filteredURLS = fileURLs.filter({$0.lastPathComponent.hasSuffix("_final.jpg")})
            
            for item in filteredURLS {
                if let image = loadImageFromURL(url: item) {
                    arrImages.append(image)
                }
            }
            // process files
            print(fileURLs)
        } catch {
            print(error)
        }

    }

    
    func loadImageFromURL(url: URL) -> UIImage? {
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
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
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoDisplayVC") as! PhotoDisplayVC
        vc.selectedImage = arrImages[indexPath.row]
        self.present(vc, animated: true)
    }


}
