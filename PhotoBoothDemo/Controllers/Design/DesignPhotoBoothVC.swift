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
    var arrStickers: [StickerView] = []
    var arrStickersRotation: [CGFloat] = []
    var arrStickersFrame: [CGRect] = []
    var arrStickersScale: [CGRect] = []
    var backgroundImageFrame: CGRect?
    var backgroundImageRotate: CGFloat?
    var backgroundImageScaleBound: CGRect?

    var currentSticker: StickerView?

    var animator: UIDynamicAnimator?
    
    var delegate: DesignPhotoBoothVCDelegate?
    var arrPhotoboothImageViews: [UIView] = []
    
    private var _selectedStickerView:StickerView?
    var selectedStickerView:StickerView? {
        get {
            return _selectedStickerView
        }
        set {
            // if other sticker choosed then resign the handler
            if _selectedStickerView != newValue {
                if let selectedStickerView = _selectedStickerView {
                    selectedStickerView.showEditingHandlers = false
                }
                _selectedStickerView = newValue
            }
            // assign handler to new sticker added
            if let selectedStickerView = _selectedStickerView {
                selectedStickerView.showEditingHandlers = true
                if selectedStickerView.tag != 1000 {
                    selectedStickerView.superview?.bringSubviewToFront(selectedStickerView)
                }
            }
        }
    }

    
    //.. Image Picker
    var currentTransform: CGAffineTransform? = nil
    var pinchStartImageCenter: CGPoint = CGPoint(x: 0, y: 0)
    let maxScale: CGFloat = 6.0
    let minScale: CGFloat = 0.09
    var currentScale: CGFloat = 1.0
    var colorPickerFrom: OpenColorPickerFrom = .layout
    
    var currentRotationAngle: CGFloat = 0.0
    var backImage: UIImage?

    //MARK: - ViewLifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        viewCenter.delegate = self
        
        setupLayoutViews()
        setupLayoutData()
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
        let tapRecognizer1 = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground1(recognizer:)))
        tapRecognizer1.numberOfTapsRequired = 1
        self.viewCenter.addGestureRecognizer(tapRecognizer1)


        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
    }
    
    
}

//MARK: - Action Methods
extension DesignPhotoBoothVC {
    @IBAction func onAddLabel(_ sender: UIButton) {
        viewCenter.addDefaultLabel(defaultFrame: CGRect(x: viewCenter.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                                        y: viewCenter.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                                        width: 60, height: 50))
        viewCenter.currentlyEditingLabel.closeView!.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_delete.png")
        viewCenter.currentlyEditingLabel.rotateView?.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_resize.png")
        viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 16
        viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 16
    }
    
    @IBAction func onSteakerAdd(_ sender: UIButton) {
        //Add the label
        let labelFrame = CGRect(x: viewCenter.bounds.midX - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                y: viewCenter.bounds.midY - CGFloat(arc4random()).truncatingRemainder(dividingBy: 20),
                                width: 50, height: 50)

        addSticker(frame: labelFrame, name: "smile_1")
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
        
        for item in arrStickers {
            item.showEditingHandlers = false
        }
        
        if let view = viewCenter.viewWithTag(1000) as? StickerView {
            view.showEditingHandlers = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.saveEverything()
        })
        
    }
    
    func saveEverything() {
        var tempSteakers: [Sticker] = []
        var tempTexts: [Text] = []
        
        print("SAVE")
        for (index,_) in self.arrStickers.enumerated() {
            
            print("Index: \(index)")
            print("Frame: \(arrStickersFrame[index])")
            
            var frame = arrStickersFrame[index]
            frame.size = arrStickersScale[index].size
                        
            tempSteakers.append(Sticker(imgName: "smile_1", location: frame,rotationAngle: arrStickersRotation[index], scale: arrStickersScale[index]))
        }
        
        layout?.steakers = tempSteakers
        
        //.. TEXT
        for item in viewCenter.labels {
            let labelItem = item as! JLStickerLabelView
            let w = labelItem.frame.width
            let h = labelItem.frame.height
            let x = labelItem.frame.origin.x
            let y = labelItem.frame.origin.y
            let location = CGRect(x: x, y: y, width: w, height: h)
            
            let text = labelItem.labelTextView.text!
    
            let hex = hexStringFromUIColor2(color: labelItem.labelTextView.textColor ?? .black)
            
            tempTexts.append(Text(text: text, location: location, rotationAngle: labelItem.rotationAngle,scale: labelItem.scale,scaleRect: labelItem.scaleRect
                                  ,font: labelItem.labelTextView.fontName,size: labelItem.labelTextView.fontSize,color: hex
                                 ))
        }
        
        layout?.texts = tempTexts
                  
        layout?.layoutBackgroundColor = (viewCenter.backgroundColor ?? .white).hexStringFromColor()
        
        //.. Layoutbackground Frame and rotate
        if backgroundImageFrame == nil {
            layout?.layoutBackgroundFrame = CGRect(x: 10, y: 10, width: 295 - 20, height: 443 - 20)
        } else {
            layout?.layoutBackgroundFrame = backgroundImageFrame
        }
        
        if backgroundImageScaleBound == nil {
            layout?.layoutBackgroundScale = CGRect(x: 10, y: 10, width: 295 - 20, height: 443 - 20)
        } else {
            layout?.layoutBackgroundScale = backgroundImageScaleBound
        }
        
        layout?.layoutBackgroundRotate = backgroundImageRotate
        
        saveImage(image: viewCenter.asImage())
    }
    
    func hexStringFromUIColor2(color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255)
        
        return String(format: "#%06x", rgb)
    }

    
    func hexStringFromColor1(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(Float(r * 255)),
                      lroundf(Float(g * 255)),
                      lroundf(Float(b * 255)))
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
        let fontNamesArray = ["Baskerville-BoldItalic", "AcademyEngravedLetPlain", "AlNile-Bold", "Chalkduster"]
        let fontName = fontNamesArray[Int(index)]
        viewCenter.fontName = fontName
    }
    
    @IBAction func selectTextFontSize(_ sender: UIButton) {
        let index = arc4random_uniform(3)
        let fontSizes = [15, 60, 20]
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
            
            print("GET")
            
            //.. Stickers
            if layout.steakers.count > 0 {
                for (index,item) in layout.steakers.enumerated() {
                    
                    print("Index: \(index)")
                    print("Frame: \(item.location)")

                    addSticker(frame: item.location, name: item.imgName, rotationAngle: item.rotationAngle, scale: item.scale)
                }
            }
            
            //.. Texts
            if layout.texts.count > 0 {
                for item in layout.texts {
                    addLabel(textModel: item)
                }
            }
            
            adBackgroundImage()
        }
    }
    
    
        
    @objc func tapBackground(recognizer: UITapGestureRecognizer) {
        
        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()

        if (selectedSticker != nil) {
            selectedSticker!.enabledControl = false
            selectedSticker!.enabledBorder = false;
            selectedSticker = nil
        }
        
        for item in arrStickers {
            item.showEditingHandlers = false
        }
        
        if let view = viewCenter.viewWithTag(1000) as? StickerView {
            view.showEditingHandlers = false
        }
    }
    
    @objc func tapBackground1(recognizer: UITapGestureRecognizer) {
        
        //.. Hide the label borders before save
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
        
        if (selectedSticker != nil) {
            selectedSticker!.enabledControl = false
            selectedSticker!.enabledBorder = false;
            selectedSticker = nil
        }
        
        for item in arrStickers {
            item.showEditingHandlers = false
        }
        
        if let view = viewCenter.viewWithTag(1000) as? StickerView {
            view.showEditingHandlers = false
        }
    }
    
    func addSticker(frame: CGRect, name: String, rotationAngle: CGFloat = 0.0, scale: CGRect? = nil) {
                
        let testImage = UIImageView.init(frame: frame)
        testImage.image = UIImage(named: "smile_1")
        testImage.contentMode = .scaleAspectFit
        let stickerView3 = StickerView.init(contentView: testImage)
        stickerView3.frame = frame
        stickerView3.delegate = self
        stickerView3.setImage(deleteImage!, forHandler: StickerViewHandler.close)
        stickerView3.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
        stickerView3.showEditingHandlers = false
        stickerView3.outlineBorderColor = .clear
        stickerView3.tag = 999
        
        self.viewCenter.addSubview(stickerView3)
        self.selectedStickerView = stickerView3
        
        stickerView3.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
        
        self.arrStickers.append(stickerView3)
        self.arrStickersRotation.append(rotationAngle)
        self.arrStickersFrame.append(frame)
        self.arrStickersScale.append(frame)

    }

    func addLabel(textModel: Text?) {
                
        viewCenter.fontName = textModel?.font ?? "HelveticaNeue"
        viewCenter.fontSize = textModel?.size ?? 20.0
        viewCenter.textColor = colorWithHexString1(hexString: textModel?.color ?? "")

        let size = CGSize(width: 207.03278410434723, height: 72.9441933631897)
        var scaleFrame = textModel?.location
        scaleFrame?.size = size
        
        viewCenter.addLabel(withText: textModel?.text ?? "", withFrame: textModel?.location ?? .zero, fontName: textModel?.font ?? "HelveticaNeue", fontSize: textModel?.size ?? 20.0, textColor: colorWithHexString1(hexString: textModel?.color ?? ""))
        
        viewCenter.currentlyEditingLabel.closeView!.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_delete.png")
        viewCenter.currentlyEditingLabel.rotateView?.image = UIImage.imageNamedForCurrentBundle(name: "IRSticker.bundle/btn_resize.png")
        viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 16
        viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 16
//        
        viewCenter.currentlyEditingLabel.transform = CGAffineTransform(rotationAngle: textModel?.rotationAngle ?? 0.0)
//        
//        if textModel?.scaleRect != nil {
//            DispatchQueue.main.async {
////                self.viewCenter.currentlyEditingLabel.bounds = textModel!.scaleRect
////                self.viewCenter.currentlyEditingLabel.adjustsWidthToFillItsContens(self.viewCenter.currentlyEditingLabel, labelView: self.viewCenter.currentlyEditingLabel.labelTextView)
////                self.viewCenter.currentlyEditingLabel.refresh()
//            }
//        }
//

    }
    
    func colorWithHexString1(hexString: String) -> UIColor {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.count != 6) && (cString.count != 8) {
            return UIColor.gray // Default color in case of wrong format
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0
        let a = (cString.count == 8) ? CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0 : 1.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
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
    
    func adBackgroundImage() {
        
        //.. Background Image
        if let image = loadImage(nameOfImage: "\(self.layout?.id ?? 0)") {
            let testImage = UIImageView.init(frame: self.viewCenter.bounds)
            testImage.image = image
            testImage.contentMode = .scaleAspectFill
            let stickerView3 = StickerView.init(contentView: testImage)
            stickerView3.frame = layout?.layoutBackgroundFrame ?? .zero
            stickerView3.delegate = self
            stickerView3.setImage(deleteImage!, forHandler: StickerViewHandler.close)
            stickerView3.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
            stickerView3.showEditingHandlers = false
            stickerView3.outlineBorderColor = .clear
            stickerView3.clipsToBounds = true
            stickerView3.tag = 1000
            self.selectedStickerView = stickerView3
            
            stickerView3.transform = CGAffineTransform(rotationAngle: CGFloat(layout?.layoutBackgroundRotate ?? 0.0))
            
            if layout?.layoutBackgroundScale != nil {
                stickerView3.bounds = layout!.layoutBackgroundScale!
                stickerView3.setNeedsDisplay()
            }
            
            if let view1 = self.viewCenter.viewWithTag(120) {
                if let viewToRemove = view1.viewWithTag(1000) {
                    viewToRemove.removeFromSuperview()
                }
                self.saveImageToDocumentDirectory(name: "layout_\(layout?.id ?? 0)_background_image", image: image)
                view1.insertSubview(stickerView3, at: 0)
            }
        }
        
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
            self.viewCenter.currentlyEditingLabel.labelTextView.textColor =  viewController.selectedColor
        }
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        print(viewController.selectedColor)
        
        let hexColor = hexStringFromColor(color: viewController.selectedColor)
        
        if colorPickerFrom == .layout {
            viewCenter.backgroundColor = colorWithHexString(hexString: hexColor)
        } else{
            self.viewCenter.currentlyEditingLabel.labelTextView.textColor =  colorWithHexString(hexString: hexColor)
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

            let testImage = UIImageView.init(frame: self.viewCenter.bounds)
            testImage.image = image
            testImage.contentMode = .scaleAspectFill
            let stickerView3 = StickerView.init(contentView: testImage)
            stickerView3.frame = CGRect(x: 10, y: 10, width: 295 - 20, height: 443 - 20)
            stickerView3.delegate = self
            stickerView3.setImage(deleteImage!, forHandler: StickerViewHandler.close)
            stickerView3.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
                stickerView3.showEditingHandlers = false
            stickerView3.outlineBorderColor = .clear
            stickerView3.clipsToBounds = true
            stickerView3.tag = 1000
            self.selectedStickerView = stickerView3
            
            if let view1 = self.viewCenter.viewWithTag(120) {
                if let viewToRemove = view1.viewWithTag(1000) {
                    viewToRemove.removeFromSuperview()
                }
                self.deleteBackgroundImageIfExists()
                self.saveImageToDocumentDirectory(name: "layout_\(layout?.id ?? 0)_background_image", image: image)
                view1.insertSubview(stickerView3, at: 0)
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
    func rotationValue() {
        printContent("ROOOO")
    }
    
    func showFontToolbar() {
        self.viewFont.isHidden = false
    }
    
    func hideFontToolbar() {
        self.viewFont.isHidden = true
    }
    
    func removeLabel(label: JLStickerLabelView) {
        for item in self.viewCenter.labels {
            if (item as! JLStickerLabelView) == label {
                self.viewCenter.labels.remove(item)
            }
        }
    }
}

extension DesignPhotoBoothVC: StickerViewDelegate {
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    
    func stickerViewDidChangeMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
    }
    
    func stickerViewDidEndMoving(_ stickerView: StickerView) {
        
        if stickerView.tag == 1000 {
            self.backgroundImageFrame = stickerView.frame
        } else {
            if let index = arrStickers.firstIndex(where: {$0 == stickerView}) {
                arrStickersFrame[index] = stickerView.frame
            }
        }
    }
    
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidChangeRotating(_ stickerView: StickerView) {
        
        if stickerView.tag == 1000 {
            self.backgroundImageFrame = stickerView.frame
            self.backgroundImageRotate = stickerView.currentRotation
            self.backgroundImageScaleBound = stickerView.currentScale
        } else {
            if let index = arrStickers.firstIndex(where: {$0 == stickerView}) {
                arrStickersFrame[index] = stickerView.frame
                arrStickersRotation[index] = stickerView.currentRotation
                
                print("CurrentScale: \(stickerView.currentScale)")
                if let scale = stickerView.currentScale {
                    arrStickersScale[index] = scale
                }
                
            }
        }
    }
    
    func stickerViewDidEndRotating(_ stickerView: StickerView) {
        
    }
    
    func stickerViewDidClose(_ stickerView: StickerView) {
        if let index = arrStickers.firstIndex(where: {$0 == stickerView}) {
            arrStickers.remove(at: index)
            arrStickersFrame.remove(at: index)
            arrStickersRotation.remove(at: index)
            arrStickersScale.remove(at: index)
        }
        
        deleteBackgroundImageIfExists()
    }
    
    func stickerViewDidTap(_ stickerView: StickerView) {
        arrStickers.forEach({ item in
            item.showEditingHandlers = false
        })
        stickerView.showEditingHandlers = true
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
    }
    
}

extension DesignPhotoBoothVC {
    
    func loadImage(nameOfImage : String) -> UIImage? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("layout_\(nameOfImage)_background_image.jpg")
            
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
    
    func saveImageToDocumentDirectory(name: String, image: UIImage ) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(name).jpg" // name of the image to be saved
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
    
    private func deleteBackgroundImageIfExists(){
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if (fileName.hasSuffix("background_image.jpg"))
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
}
