//
//  ViewController.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 15/11/23.
//

import UIKit

class DesignPhotoBoothVC: UIViewController {
    
    @IBOutlet weak var viewMain: UIView!

    @IBOutlet weak var collectionView: UICollectionView!

    var mainLayoutModel: ViewsLayout?
    var layout: Layout?
    @IBOutlet weak var viewCenter: UIView!

    var indexSelected = 0
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!


    override func viewDidLoad() {
        super.viewDidLoad()
    

        // Create the custom view
        if layout?.indexSelected == 0 {
            let myCustomView: _4x6Layout1 = _4x6Layout1.fromNib()
            // Add the subview to the cell
            
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            // Add the subview to the cell
            self.viewCenter.addSubview(myCustomView)
            // Constraints for myCustomView to match cell size
            NSLayoutConstraint.activate([
                myCustomView.topAnchor.constraint(equalTo: self.viewCenter.topAnchor),
                myCustomView.bottomAnchor.constraint(equalTo: self.viewCenter.bottomAnchor),
                myCustomView.leadingAnchor.constraint(equalTo: self.viewCenter.leadingAnchor),
                myCustomView.trailingAnchor.constraint(equalTo: self.viewCenter.trailingAnchor)
            ])
            
        } else if layout?.indexSelected == 1 {
            let myCustomView: _4x6Layout2 = _4x6Layout2.fromNib()
            // Add the subview to the cell
            
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            // Add the subview to the cell
            self.viewCenter.addSubview(myCustomView)
            // Constraints for myCustomView to match cell size
            NSLayoutConstraint.activate([
                myCustomView.topAnchor.constraint(equalTo: self.viewCenter.topAnchor),
                myCustomView.bottomAnchor.constraint(equalTo: self.viewCenter.bottomAnchor),
                myCustomView.leadingAnchor.constraint(equalTo: self.viewCenter.leadingAnchor),
                myCustomView.trailingAnchor.constraint(equalTo: self.viewCenter.trailingAnchor)
            ])
            
        } 
                
    }
    
//    func addShapes(shapeLayout: LayoutModel) {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: shapeLayout.shapeImage)
//        
//        // adding constraints to profileImageView
//        viewMain.addSubview(imageView)
//        // Disable autoresizing masks translation for the image view
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Set up constraints for top, bottom, leading, and trailing
//        let topConstraint = imageView.topAnchor.constraint(equalTo: viewMain.topAnchor, constant: shapeLayout.top) // 10 is an example padding value
//        let bottomConstraint = imageView.bottomAnchor.constraint(equalTo: viewMain.bottomAnchor, constant: -shapeLayout.bottom) // Negative for inset from bottom
//        let leadingConstraint = imageView.leadingAnchor.constraint(equalTo: viewMain.leadingAnchor, constant: shapeLayout.leading) // Leading padding
//        let trailingConstraint = imageView.trailingAnchor.constraint(equalTo: viewMain.trailingAnchor, constant: -shapeLayout.trailing) // Trailing padding
//        
//        // Activate constraints
//        NSLayoutConstraint.activate([
//            topConstraint,
//            bottomConstraint,
//            leadingConstraint,
//            trailingConstraint
//        ])
//        
//        // Optional: Set content mode for the image view
//        imageView.contentMode = .scaleAspectFit
//    }
//    
    @IBAction func btnCamera(sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCameraViewController") as! CustomCameraViewController
        vc.layout = self.layout
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createAndLayoutImageViews(viewMain: UIView, using layout: ViewsLayout) {
        var previousView: UIImageView?
        
        for viewLayout in layout.views {
            let imageView = UIImageView()
            imageView.contentMode = .scaleToFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: viewLayout.imageName)
            viewMain.addSubview(imageView)
            
            // Leading and Trailing Constraints
            imageView.leadingAnchor.constraint(equalTo: viewMain.leadingAnchor, constant: viewLayout.leading.constant).isActive = true
            imageView.trailingAnchor.constraint(equalTo: viewMain.trailingAnchor, constant: viewLayout.trailing.constant).isActive = true
            
            // Top Constraint
            if let previousView = previousView {
                imageView.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: viewLayout.top.constant).isActive = true
            } else {
                imageView.topAnchor.constraint(equalTo: viewMain.topAnchor, constant: viewLayout.top.constant).isActive = true
            }
            
            // Bottom or Height Constraint
            if let bottomConstraint = viewLayout.bottom {
                imageView.bottomAnchor.constraint(equalTo: viewMain.bottomAnchor, constant: -bottomConstraint.constant).isActive = true
            } else {
                imageView.heightAnchor.constraint(equalToConstant: viewLayout.height!).isActive = true
            }
            
            previousView = imageView
        }
    }


}
