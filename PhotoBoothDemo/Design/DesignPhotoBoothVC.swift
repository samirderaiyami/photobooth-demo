//
//  ViewController.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 15/11/23.
//

import UIKit

protocol DesignPhotoBoothVCDelegate {
    func updateListUI()
}

class DesignPhotoBoothVC: UIViewController {
    
    @IBOutlet weak var viewMain: UIView!

    @IBOutlet weak var collectionView: UICollectionView!

    var mainLayoutModel: ViewsLayout?
    var layout: Layout?
    @IBOutlet weak var viewCenter: JLStickerImageView!

    var indexSelected = 0
    var selectedSticker: IRStickerView?
    var animator: UIDynamicAnimator?

    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    
    var delegate: DesignPhotoBoothVCDelegate?
    var arrPhotoboothImageViews: [UIView] = []

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
            arrPhotoboothImageViews.append(myCustomView.view1)
            arrPhotoboothImageViews.append(myCustomView.view2)
            arrPhotoboothImageViews.append(myCustomView.view3)
            

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
            arrPhotoboothImageViews.append(myCustomView.view1)

        } 
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        setupLayoutData()
    }
    
    func setupLayoutData() {
        //.. Stickers
        if let layout = layout {
            if layout.steakers.count > 0 {
                for item in layout.steakers {
                    addSticker(frame: item.location, name: item.imgName)
                }
            }
        }
        
        //.. Images
        if let images = layout?.images {
            for (index,item) in images.enumerated() {
                let currentView = arrPhotoboothImageViews[index]
                let imageView = UIImageView()
                imageView.backgroundColor = UIColor.red
                imageView.image = UIImage(data: item)
                imageView.frame = currentView.bounds
                imageView.contentMode = .scaleToFill
                currentView.addSubview(imageView)
            }
        }
        
    }
    
    @objc func tapBackground(recognizer: UITapGestureRecognizer) {
        if (selectedSticker != nil) {
            selectedSticker!.enabledControl = false
            selectedSticker!.enabledBorder = false;
            selectedSticker = nil
        }
    }
    func addSticker(frame: CGRect, name: String) {
        let sticker = IRStickerView(frame: frame, contentImage: UIImage.init(named: "\(name)")!)
        sticker.stickerMinScale = 0
        sticker.stickerMaxScale = 0
        sticker.enabledControl = false
        sticker.enabledBorder = false
        sticker.tag = 3
        sticker.delegate = self
        viewCenter.addSubview(sticker)
    }
    
    @IBAction func onAddLabel(_ sender: UIButton) {
        //Add the label
        viewCenter.addLabel()
        
        //Modify the Label
        viewCenter.textColor = UIColor.black
        viewCenter.textAlpha = 1
        
        viewCenter.currentlyEditingLabel.closeView!.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_delete.png")
        viewCenter.currentlyEditingLabel.rotateView?.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_resize.png")
        viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 16
        viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 16
        
    }
    
    @IBAction func onSteakerAdd(_ sender: UIButton) {
        //Add the label
        addSticker(frame: CGRect(x: 0, y: 0, width: 50, height: 50), name: "smile_1")
    }
    
    @IBAction func btnCamera(sender: UIButton) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCameraViewController") as! CustomCameraViewController
        vc.layout = self.layout
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSaveImage(_ sender: UIButton) {
        
        var tempSteakers: [Sticker] = []
        
        for item in self.viewCenter.subviews {
            if item is IRStickerView {
                let w = (item as! IRStickerView).contentView.frame.width
                let h = (item as! IRStickerView).contentView.frame.height
                
                let x = item.frame.origin.x
                let y = item.frame.origin.y
                
                tempSteakers.append(Sticker(imgName: "smile_1", location: CGRect(x: x, y: y, width: w, height: h)))
            }
        }

        layout?.steakers = tempSteakers
                
        if let data = viewCenter.asImage().jpegData(compressionQuality: 0.5) {
            saveImage(image: data)
        }
        
    }
    
    func saveImage(image: Data) {
        layout?.previewImage = image
        if let layout {
            Layout.updateUserEditedVideos(VideoModel: layout)
        }
        delegate?.updateListUI()

    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            
            print(error.localizedDescription)
            
        } else {
            
            print("Success")
        }
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
extension DesignPhotoBoothVC: IRStickerViewDelegate {
    // MARK: - StickerViewDelegate
    func ir_StickerView(stickerView: IRStickerView, imageForRightTopControl recommendedSize: CGSize) -> UIImage? {
        if stickerView.tag == 1 {
            return UIImage.init(named: "btn_smile.png")
        }
        
        return nil
    }
    
    func ir_StickerView(stickerView: IRStickerView, imageForLeftBottomControl recommendedSize: CGSize) -> UIImage? {
        if stickerView.tag == 1 || stickerView.tag == 2 {
            return UIImage.init(named: "btn_flip.png")
        }
        
        return nil
    }
    
    func ir_StickerViewDidTapContentView(stickerView: IRStickerView) {
        NSLog("Tap[%zd] ContentView", stickerView.tag)
        if let selectedSticker = selectedSticker {
            selectedSticker.enabledBorder = false
            selectedSticker.enabledControl = false
        }
        
        selectedSticker = stickerView
        selectedSticker!.enabledBorder = true
        selectedSticker!.enabledControl = true
    }
    
    func ir_StickerViewDidTapLeftTopControl(stickerView: IRStickerView) {
        NSLog("Tap[%zd] DeleteControl", stickerView.tag);
        stickerView.removeFromSuperview()
        for subView in view.subviews {
            if subView.isKind(of: IRStickerView.self)  {
                let sticker = subView as! IRStickerView
                sticker.performTapOperation()
                break
            }
        }
    }
    
    func ir_StickerViewDidTapLeftBottomControl(stickerView: IRStickerView) {
        NSLog("Tap[%zd] LeftBottomControl", stickerView.tag);
        let targetOrientation = (stickerView.contentImage?.imageOrientation == UIImage.Orientation.up ? UIImage.Orientation.upMirrored : UIImage.Orientation.up)
        let invertImage = UIImage.init(cgImage: (stickerView.contentImage?.cgImage)!, scale: 1.0, orientation: targetOrientation)
        stickerView.contentImage = invertImage
    }
    
    func ir_StickerViewDidTapRightTopControl(stickerView: IRStickerView) {
        NSLog("Tap[%zd] RightTopControl", stickerView.tag);
        animator?.removeAllBehaviors()
        let snapbehavior = UISnapBehavior.init(item: stickerView, snapTo: view.center)
        snapbehavior.damping = 0.65;
        animator?.addBehavior(snapbehavior)
    }
}
