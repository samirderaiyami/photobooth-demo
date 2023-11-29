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

enum OpenColorPickerFrom {
    case layout
    case text
}

class DesignPhotoBoothVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var viewFont: UIView!
    @IBOutlet weak var viewCenter: JLStickerImageView!

    //MARK: - Variables
    var layout: Layout?
    
    var selectedSticker: IRStickerView?
    var animator: UIDynamicAnimator?
    
    var delegate: DesignPhotoBoothVCDelegate?
    var arrPhotoboothImageViews: [UIView] = []
    
    
    //.. Image Picker
    var currentTransform: CGAffineTransform? = nil
    var pinchStartImageCenter: CGPoint = CGPoint(x: 0, y: 0)
    let maxScale: CGFloat = 6.0
    let minScale: CGFloat = 0.09
    var currentScale: CGFloat = 1.0
    var colorPickerFrom: OpenColorPickerFrom = .layout
    
    //MARK: - ViewLifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        viewCenter.delegate = self
        
        setupLayoutViews()
        setupLayoutData()
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
    }
    
    
}

//MARK: - Action Methods
extension DesignPhotoBoothVC {
    @IBAction func onAddLabel(_ sender: UIButton) {
        //Add the label
        let labelFrame = CGRect(x: viewCenter.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                y: viewCenter.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                width: 60, height: 50)
        
        addLabel(withText: "ENTER TEXT", withFrame: labelFrame)
    }
    
    @IBAction func onSteakerAdd(_ sender: UIButton) {
        //Add the label
        addSticker(frame: CGRect(x: 0, y: 0, width: 50, height: 50), name: "smile_1")
    }
    
    @IBAction func btnCamera(sender: UIButton) {
        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCameraViewController") as! CustomCameraViewController
        vc.layout = self.layout
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDeleteTemplate(_ sender: UIButton) {
        Layout.deleteUserEditedVideos(id: self.layout?.id ?? 0)
        delegate?.updateListUI()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLayoutColor(sender: UIButton) {
        let picker = UIColorPickerViewController()
        // Setting the Initial Color of the Picker
        picker.selectedColor = .red
        
        // Settig Delegate
        picker.delegate = self
        
        // Presenting the Color Picker
        
        colorPickerFrom = .layout
        
        self.present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSaveLayout(_ sender: UIButton) {
        
        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
        
        var tempSteakers: [Sticker] = []
        var tempTexts: [Text] = []
        
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
        
        for item in self.viewCenter.subviews {
            if item is JLStickerLabelView {
                
                let w = (item as! JLStickerLabelView).frame.width
                let h = (item as! JLStickerLabelView).frame.height
                let x = item.frame.origin.x
                let y = item.frame.origin.y
                let location = CGRect(x: x, y: y, width: w, height: h)
                
                let text = (item as! JLStickerLabelView).labelTextView.text!
                tempTexts.append(Text(text: text, location: location))
            }
        }
        
        layout?.texts = tempTexts
        
        layout?.layoutBackgroundColor = (viewCenter.backgroundColor ?? .white).hexStringFromColor()
        
        saveImage(image: viewCenter.asImage())
        
        
    }
    
    @IBAction func btnBackgroundImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true)
    }

    //.. TEXT METHODS
    @IBAction func editText(_ sender: UIButton) {
        self.viewCenter?.becomeFirstResponder()
    }
    
    @IBAction func selectTextFont(_ sender: UIButton) {
        let index = arc4random_uniform(3)
        var fontNamesArray = ["AcademyEngravedLetPlain", "AlNile-Bold", "Chalkduster"]
        let fontName = fontNamesArray[Int(index)]
        viewCenter.fontName = fontName
    }
    
    @IBAction func selectTextFontSize(_ sender: UIButton) {
        let index = arc4random_uniform(3)
        var fontSizes = [15, 60, 20]
        let textAlpha = fontSizes[Int(index)]
        viewCenter.fontSize = CGFloat(textAlpha)
        viewCenter.layoutIfNeeded()
    }
    
    @IBAction func selectTextColor(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        // Setting the Initial Color of the Picker
        picker.selectedColor = .red
        
        // Settig Delegate
        picker.delegate = self
        
        colorPickerFrom = .text
        
        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }


}

//MARK: - Custom Methods
extension DesignPhotoBoothVC {
    
    func setupLayoutViews() {
        // Create the custom view
        if layout?.indexSelected == 0 {
            let myCustomView: _4x6Layout1 = _4x6Layout1.fromNib()
            // Add the subview to the cell
            
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            // Add the subview to the cell
            myCustomView.tag = 120
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
            myCustomView.tag = 120
            
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
    }
    
    func setupLayoutData() {
        
        if let layout = layout {
            
            //.. Background Color
            viewCenter.backgroundColor = UIColor.hexStringToUIColor(hex: layout.layoutBackgroundColor ?? "ffffff")
            
            //.. Stickers
            if layout.steakers.count > 0 {
                for item in layout.steakers {
                    addSticker(frame: item.location, name: item.imgName)
                }
            }
            
            //.. Texts
            if layout.texts.count > 0 {
                for item in layout.texts {
                    addLabel(withText: item.text, withFrame: item.location)
                }
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
        
        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
        
        let sticker = IRStickerView(frame: frame, contentImage: UIImage.init(named: "\(name)")!)
        sticker.stickerMinScale = 0
        sticker.stickerMaxScale = 0
        sticker.enabledControl = false
        sticker.enabledBorder = false
        sticker.tag = 3
        sticker.delegate = self
        viewCenter.addSubview(sticker)
    }

    func addLabel(withText: String, withFrame: CGRect) {
        
        viewCenter.addLabel(withText: withText, withFrame: withFrame)
        
        //Modify the Label
        viewCenter.textColor = UIColor.black
        viewCenter.textAlpha = 1
        
        viewCenter.currentlyEditingLabel.closeView!.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_delete.png")
        viewCenter.currentlyEditingLabel.rotateView?.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_resize.png")
        viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 16
        viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 16
    }
    
    func saveImage(image: UIImage) {
        
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        layout?.previewImage = data
        
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

//MARK:- UIColorPickerViewControllerDelegate
@available(iOS 14.0, *)
extension DesignPhotoBoothVC: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print(viewController.selectedColor)
        if colorPickerFrom == .layout {
            self.viewCenter.backgroundColor = viewController.selectedColor
        } else{
            self.viewCenter.textColor = viewController.selectedColor
        }
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        print(viewController.selectedColor)
        
        let hexColor = hexStringFromColor(color: viewController.selectedColor)
        
        if colorPickerFrom == .layout {
            viewCenter.backgroundColor = colorWithHexString(hexString: hexColor)
        } else{
            self.viewCenter.textColor = colorWithHexString(hexString: hexColor)
        }
        
    }
    
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
    }
    func colorWithHexString(hexString: String) -> UIColor {
        var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()
        
        print(colorString)
        let alpha: CGFloat = 1.0
        let red: CGFloat = self.colorComponentFrom(colorString: colorString, start: 0, length: 2)
        let green: CGFloat = self.colorComponentFrom(colorString: colorString, start: 2, length: 2)
        let blue: CGFloat = self.colorComponentFrom(colorString: colorString, start: 4, length: 2)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {
        
        let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
        let endIndex = colorString.index(startIndex, offsetBy: length)
        let subString = colorString[startIndex..<endIndex]
        let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt32 = 0
        
        guard Scanner(string: String(fullHexString)).scanHexInt32(&hexComponent) else {
            return 0
        }
        let hexFloat: CGFloat = CGFloat(hexComponent)
        let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
        print(floatValue)
        return floatValue
    }
    
    
}



extension DesignPhotoBoothVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.tag = 10051
            imageView.isUserInteractionEnabled = true
            imageView.frame = CGRect(x: 0, y: 0, width: viewCenter.frame.width, height: viewCenter.frame.height)
            if let viewToRemove = viewCenter.viewWithTag(10051) {
                viewToRemove.removeFromSuperview()
            }
            
            //Gesture for moving position of image
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(imageGestureHandler(gesture:)))
            panGesture.maximumNumberOfTouches = 1
            panGesture.minimumNumberOfTouches = 1
            imageView.addGestureRecognizer(panGesture)
            
            //Gesture for rotating image
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotatedImage(rotateGesture:)))
            imageView.addGestureRecognizer(rotate)
            
            //Gesture for pinch image, change scale of image via zooming and zoom-out
            let pinchGetsture = UIPinchGestureRecognizer(target: self, action: #selector(pinchActionZoomImage(imagePinchGesture:)))
            pinchGetsture.delegate = self
            imageView.addGestureRecognizer(pinchGetsture)
            
            if let view1 = self.viewCenter.viewWithTag(120) {
                view1.insertSubview(imageView, at: 0)
            }
            picker.dismiss(animated: true)
        }
        
    }
}


extension DesignPhotoBoothVC: UIGestureRecognizerDelegate {
    
    @objc func rotatedImage(rotateGesture: UIRotationGestureRecognizer) {
        guard let subImageView = rotateGesture.view else {
            return
        }
        
        if (rotateGesture.state == .changed) {
            subImageView.transform = subImageView.transform.rotated(by: rotateGesture.rotation)
            rotateGesture.rotation = 0
        }
    }
    
    @objc func pinchActionZoomImage(imagePinchGesture: UIPinchGestureRecognizer) {
        
        guard let subImageView = imagePinchGesture.view else {
            return
        }
        
        if imagePinchGesture.state == .began { // Begin pinch
            // Store current transfrom of UIImageView
            self.currentTransform = subImageView.transform
            
            // Store initial loaction of pinch action
            self.pinchStartImageCenter = subImageView.center
        }
        else if imagePinchGesture.state == .changed {
            let pinchCenter = CGPoint(x: imagePinchGesture.location(in: subImageView).x - subImageView.bounds.midX,
                                      y: imagePinchGesture.location(in: subImageView).y - subImageView.bounds.midY)
            let transform = subImageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: imagePinchGesture.scale, y: imagePinchGesture.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            subImageView.transform = transform
            imagePinchGesture.scale = 1
        }
        
        if (imagePinchGesture.state == .ended) {
            let currentScale = sqrt(abs(subImageView.transform.a * subImageView.transform.d - subImageView.transform.b * subImageView.transform.c))
            if currentScale <= self.minScale { // Under lower scale limit
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {() -> Void in
                    subImageView.center = CGPoint(x: subImageView.frame.size.width / 2, y: subImageView.frame.size.height / 2)
                    subImageView.frame = CGRect(x: subImageView.frame.origin.x, y: subImageView.frame.origin.y, width: subImageView.frame.size.width, height: subImageView.frame.size.height)
                }, completion: nil)
            } else if self.maxScale <= currentScale { // Upper higher scale limit
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {() -> Void in}, completion: nil)
            }
            else {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {() -> Void in}, completion: nil)
            }
            
        }
        
    }
    
    //Move object to view
    @objc func imageGestureHandler(gesture: UIPanGestureRecognizer) {
        if let gestureView = gesture.view {
            // Store current transfrom of UIImageView
            let transform = gestureView.transform
            
            // Initialize imageView.transform
            gestureView.transform = CGAffineTransform.identity
            
            // Move UIImageView
            let point: CGPoint = gesture.translation(in: viewCenter)
            let movedPoint = CGPoint(x: gestureView.center.x + point.x,
                                     y: gestureView.center.y + point.y)
            gestureView.center = movedPoint
            
            // Revert imageView.transform
            gestureView.transform = transform
            
            // Reset translation
            gesture.setTranslation(CGPoint.zero, in: gestureView)
        }
        
    }
}

extension DesignPhotoBoothVC: JLStickerImageViewDelegate {
    func showFontToolbar() {
        self.viewFont.isHidden = false
    }
    
    func hideFontToolbar() {
        self.viewFont.isHidden = true
    }
}
