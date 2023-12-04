//
//  LayoutListVC.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 21/11/23.
//

import UIKit

class PhotoDisplayVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = selectedImage
        
    }
    

    @IBAction func btnClose(sender: UIButton) {
        self.dismiss(animated: true)
    }

}
