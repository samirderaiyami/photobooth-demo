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
    
    var arrStickers: [StickerView] = []
    var arrStickersRotation: [CGFloat] = []
    var arrStickersFrame: [CGRect] = []
    var arrStickersScale: [CGRect] = []
        
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
    var colorPickerFrom: OpenColorPickerFrom = .layout
    
    //.. Background
    var currentBackgroundImage: UIImage?
    var defaultBackgroundImageFrame: CGRect {
        return CGRect(x: 10, y: 5, width: 295 - 20, height: 443 - 10)
    }
    var backgroundImageFrame: CGRect?
    var backgroundImageRotate: CGFloat = 0.0
    var backgroundImageScaleBound: CGRect?
    
    //.. TEXT
    @IBOutlet weak var heightOfMainToolbar: NSLayoutConstraint!
    @IBOutlet weak var stackMainToolBar: UIStackView!
    @IBOutlet weak var heightOfFontToolbar: NSLayoutConstraint!

    var arrTextsRotation: [CGFloat] = []
    
    //MARK: - ViewLifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        viewCenter.delegate = self
        
        setupLayoutViews()
        setupLayoutData()
        showHideFontToolbar(isShow: false)
        
        self.setupTapOutSideGesture()
        
        //.. HIDE HANDLERS
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
    }
    
}

//MARK: - Action Methods
extension DesignPhotoBoothVC {
    @IBAction func onAddLabel(_ sender: UIButton) {
        
        self.hideAllHandlers()

        viewCenter.addDefaultLabel(defaultFrame: CGRect(x: viewCenter.frame.width / 2.0 - 30,
                                                        y: viewCenter.frame.height / 2.0 - 25,
                                                        width: 60, height: 50))
        viewCenter.currentlyEditingLabel.closeView!.image = deleteImage
        viewCenter.currentlyEditingLabel.rotateView?.image = resizeImage
        viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 9
        viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 9
        
        arrTextsRotation.append(0.0)
        self.showHideFontToolbar(isShow: true)
        
        //.. Hide sticker Handles
        self.selectedStickerView?.showEditingHandlers = false

    }
    
    @IBAction func onSteakerAdd(_ sender: UIButton) {
        //Add the label
        self.hideAllHandlers()

        addDefaultSticker()
    }
    
    @IBAction func btnCamera(sender: UIButton) {
        self.saveEverything()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomCameraVC") as! CustomCameraVC
            vc.layout = self.layout
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @IBAction func btnBack(sender: UIButton) {
        saveEverything()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func btnDeleteTemplate(_ sender: UIButton) {
        deleteBackgroundImageIfExists() 
        Layout.deleteUserEditedVideos(id: self.layout?.id ?? 0)
        delegate?.updateListUI()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLayoutColor(sender: UIButton) {
        
        self.hideAllHandlers()

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
        saveEverything()
    }
    
    func saveEverything() {
                
        self.hideAllHandlers()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            //.. SAVE TEXT
            self.saveTexts()
                  
            self.saveImage(image: self.viewCenter.asImage())
             
            //.. SAVE BACKGROUND COLOR
            self.layout?.layoutBackgroundColor = (self.viewCenter.backgroundColor ?? .white).hexStringFromColor()
            
            //.. SAVE STICKER
            self.saveSticker()
            
            //.. SAVE BACKGROUND IMAGE
            self.saveBackgroundImage()
            
            //.. UPDATE MAIN MODEL
            if let layout = self.layout {
                Layout.updateUserEditedVideos(VideoModel: layout)
            }
            
            self.delegate?.updateListUI()
        })

    }
    
    func saveTexts() {
        
        var tempTexts: [Text] = []

        for (index,item) in viewCenter.labels.enumerated() {
            let labelItem = item as! JLStickerLabelView
            
            let w = labelItem.frame.width
            let h = labelItem.frame.height
            let x = labelItem.frame.origin.x
            let y = labelItem.frame.origin.y
            let location = CGRect(x: x, y: y, width: w, height: h)
            
            let text = labelItem.labelTextView.text!
            let hex = hexStringFromUIColor2(color: labelItem.labelTextView.textColor ?? .black)
            let size = labelItem.labelTextView.fontSize
            let fontName = labelItem.labelTextView.fontName

            tempTexts.append(Text(text: text
                                  ,location: location
                                  ,rotationAngle: arrTextsRotation[index]
                                  ,scale: .zero
                                  ,scaleRect: .zero
                                  ,font: fontName
                                  ,size: size
                                  ,color: hex ))
            
            
//            tempTexts.append(Text(text: text, location: location, rotationAngle: labelItem.rotationAngle,scale: labelItem.scale,scaleRect: labelItem.scaleRect
//                                  ,font: labelItem.labelTextView.fontName,size: labelItem.labelTextView.fontSize,color: hex
//                                 ))
        }
        
        layout?.texts = tempTexts
    }
    
    func saveSticker() {
        var tempSteakers: [Sticker] = []
        
        for (index,_) in self.arrStickers.enumerated() {
            tempSteakers.append(Sticker(imgName: "smile_1", location: arrStickersFrame[index],rotationAngle: arrStickersRotation[index], scale: arrStickersScale[index]))
        }
        layout?.steakers = tempSteakers
    }
    
    func saveBackgroundImage() {
        if let currentBackgroundImage {
            
            //.. FRAME
            if backgroundImageFrame == nil {
                layout?.layoutBackgroundFrame = self.defaultBackgroundImageFrame
            } else {
                layout?.layoutBackgroundFrame = backgroundImageFrame
            }
            
            //.. ROTATION
            layout?.layoutBackgroundRotate = backgroundImageRotate
            
            //.. SCALE
            if backgroundImageScaleBound != nil {
                layout?.layoutBackgroundScale = backgroundImageScaleBound
            }
            
            saveBackgroundImage(image: currentBackgroundImage)
        } else {
            self.deleteBackgroundImageIfExists()
        }
    }

    @IBAction func btnBackgroundImage(_ sender: UIButton) {
        self.hideAllHandlers()
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
        viewCenter.adjustsWidthToFillItsContens(viewCenter.currentlyEditingLabel, labelView: viewCenter.currentlyEditingLabel.labelTextView)
    }
    
    @IBAction func selectTextFontSize(_ sender: UIButton) {
        let number = CGFloat(Int.random(in: 20 ..< 50))
        print("Number: \(number)")
        viewCenter.fontSize = number
        viewCenter.currentlyEditingLabel.labelTextView.fontSize = number
        viewCenter.adjustsWidthToFillItsContens(viewCenter.currentlyEditingLabel, labelView: viewCenter.currentlyEditingLabel.labelTextView)
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
        
//        // Create the custom view
//        if layout?.indexSelected == 0 {
//            addConstraintAndSubViews(myCustomView: _4x6Layout1.fromNib())
//        } else if layout?.indexSelected == 1 {
//            addConstraintAndSubViews(myCustomView: _4x6Layout2.fromNib())
//        }
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
            
            //.. TEXT LABELS
            if layout.texts.count > 0 {
                for item in layout.texts {
                    addLabel(textModel: item)
                }
            }
            
            //.. BACKGROUND COLOR
            viewCenter.backgroundColor = UIColor.hexStringToUIColor(hex: layout.layoutBackgroundColor ?? "ffffff")

            //.. STICKERS
            if layout.steakers.count > 0 {
                
                for (index,item) in layout.steakers.enumerated() {
                    showSticker(index: index, sticker: item)
                }
            }
            
            //.. BACKGROUND IMAGE
            self.showBackgroundImage()
        }
    }
    
    func setupTapOutSideGesture() {
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)

        let tapRecognizer1 = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground1(recognizer:)))
        tapRecognizer1.numberOfTapsRequired = 1
        self.viewCenter.addGestureRecognizer(tapRecognizer1)
        
        if let view = viewCenter.viewWithTag(1000) {
            let tapRecognizer2 = UITapGestureRecognizer.init(target: self, action:#selector(tapBackground2(recognizer:)))
            tapRecognizer2.numberOfTapsRequired = 1
            view.addGestureRecognizer(tapRecognizer2)
        }
    }
    
    func showHideFontToolbar(isShow: Bool) {
        if isShow {
            heightOfMainToolbar.constant = 0
            stackMainToolBar.isHidden = true
            heightOfFontToolbar.constant = 30
            viewFont.isHidden = false
        } else {
            heightOfMainToolbar.constant = 30
            stackMainToolBar.isHidden = false
            heightOfFontToolbar.constant = 0
            viewFont.isHidden = true
        }
    }
    
    func hideAllHandlers() {
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
        self.selectedStickerView?.showEditingHandlers = false
        if let view = viewCenter.viewWithTag(1000) as? StickerView {
            view.showEditingHandlers = false
        }
    }
    
        
    @objc func tapBackground(recognizer: UITapGestureRecognizer) {
        hideAllHandlers()
    }
    
    @objc func tapBackground1(recognizer: UITapGestureRecognizer) {
        hideAllHandlers()
    }
    
    @objc func tapBackground2(recognizer: UITapGestureRecognizer) {
        hideAllHandlers()
    }
    
    func addDefaultSticker() {
        
        let labelFrame = CGRect(x: viewCenter.frame.width / 2.0 - 40,
                                y: viewCenter.frame.height / 2.0 - 40,
                                width: 80, height: 80)

        let stickerView = createBackgroundSticker(image: UIImage(named: "smile_1")!, layout: self.layout!, defaultFrame: labelFrame, isNormalSticker: true)
        self.viewCenter.addSubview(stickerView)
        self.selectedStickerView = stickerView
        
        self.arrStickers.append(stickerView)
        self.arrStickersFrame.append(labelFrame)
        self.arrStickersRotation.append(0.0)
        self.arrStickersScale.append(.zero)

    }
    
    func showSticker(index: Int, sticker: Sticker) {
        
        let stickerView = self.createNormalSticker(image: UIImage(named: "smile_1")!, stickerFrame: sticker.location)
        
        self.viewCenter.addSubview(stickerView)

        self.arrStickers.append(stickerView)
        self.arrStickersFrame.append(sticker.location)
        self.arrStickersRotation.append(sticker.rotationAngle)
        self.arrStickersScale.append(sticker.scale)

        //.. ROTATION
        stickerView.transform = CGAffineTransform(rotationAngle: CGFloat(sticker.rotationAngle))
        
        //.. SCALE
        if sticker.scale != .zero {
            stickerView.bounds = sticker.scale
            stickerView.setNeedsDisplay()
        }
        
    }


    func addLabel(textModel: Text?) {
            
        if let textModel {
            
            viewCenter.addLabel(textModel: textModel)
            
            self.viewCenter.textColor = colorWithHexString(hexString: textModel.color)

            viewCenter.currentlyEditingLabel.closeView!.image = deleteImage
            viewCenter.currentlyEditingLabel.rotateView?.image = resizeImage
            viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 9
            viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 9
    
            arrTextsRotation.append(textModel.rotationAngle)
        }
        

    }
    
    func saveImage(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        layout?.previewImage = data
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            
            print(error.localizedDescription)
            
        } else {
            
            print("Success")
        }
    }
    
    func showBackgroundImage() {
        
        //.. Background Image
        if let image = loadImage(nameOfImage: "\(self.layout?.id ?? 0)"), let layout = self.layout {
            
            //.. Restore variables
            self.currentBackgroundImage = image
            self.backgroundImageRotate = layout.layoutBackgroundRotate
            
            if let scaleBounds = layout.layoutBackgroundScale {
                self.backgroundImageScaleBound = scaleBounds
            }
            
            if let frame = layout.layoutBackgroundFrame {
                self.backgroundImageFrame = frame
            }
            
            let stickerView = createBackgroundSticker(image: image, layout: layout, isNormalSticker: false)
            
            if let view1 = self.viewCenter.viewWithTag(120) {
                if let viewToRemove = view1.viewWithTag(1000) {
                    viewToRemove.removeFromSuperview()
                }
                view1.insertSubview(stickerView, at: 0)
            }
            
            //.. ROTATE
            stickerView.transform = CGAffineTransform(rotationAngle: CGFloat(layout.layoutBackgroundRotate))
            
            //.. SCALE
            if let scale = layout.layoutBackgroundScale {
                stickerView.bounds = scale
                stickerView.setNeedsDisplay()
            }
            
        }
        
    }
    
    func createBackgroundSticker(image: UIImage, layout: Layout, defaultFrame: CGRect? = nil, isNormalSticker: Bool) -> StickerView {
        let testImage = UIImageView()
        testImage.image = image
        testImage.contentMode = .scaleAspectFill
        
        let stickerView = StickerView.init(contentView: testImage)
        stickerView.frame = (defaultFrame == nil) ? layout.layoutBackgroundFrame ?? .zero : defaultFrame!
        stickerView.delegate = self
        stickerView.setImage(deleteImage!, forHandler: StickerViewHandler.close)
        stickerView.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
        stickerView.showEditingHandlers = false
        stickerView.outlineBorderColor = .clear
        stickerView.clipsToBounds = true
        stickerView.tag = isNormalSticker ? 999 : 1000
        return stickerView
    }
    
    func createNormalSticker(image: UIImage, stickerFrame: CGRect) -> StickerView {
        let testImage = UIImageView()
        testImage.image = image
        testImage.contentMode = .scaleAspectFill
        
        let stickerView = StickerView.init(contentView: testImage)
        stickerView.frame = stickerFrame
        stickerView.delegate = self
        stickerView.setImage(deleteImage!, forHandler: StickerViewHandler.close)
        stickerView.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
        stickerView.showEditingHandlers = false
        stickerView.outlineBorderColor = .clear
        stickerView.clipsToBounds = true
        stickerView.tag = 999
        return stickerView
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
            self.viewCenter.textColor = colorWithHexString(hexString: hexColor)
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
}

extension DesignPhotoBoothVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            currentBackgroundImage = image
            
            
            let stickerView = createBackgroundSticker(image: image, layout: layout!, defaultFrame: defaultBackgroundImageFrame, isNormalSticker: false)
            
            self.selectedStickerView = stickerView
            
            if let view1 = self.viewCenter.viewWithTag(120) {
                if let viewToRemove = view1.viewWithTag(1000) {
                    viewToRemove.removeFromSuperview()
                }
                view1.insertSubview(stickerView, at: 0)
            }
            picker.dismiss(animated: true)
        }
        
    }
    
    private func saveBackgroundImage(image: UIImage) {
        self.deleteBackgroundImageIfExists()
        self.saveImageToDocumentDirectory(name: "layout_\(layout?.id ?? 0)_background_image", image: image)
    }
}

extension DesignPhotoBoothVC: JLStickerImageViewDelegate {
    
    func labelViewChangeEditing(label: JLStickerLabelView, rotationAngle: CGFloat) {
        print("-==-=-==-=-=-=-=-==-=-=-=-")
//        print(rotationAngle)
        for (index,item) in viewCenter.labels.enumerated() {
            let itemLabel = item as! JLStickerLabelView
            
            if itemLabel == label {
                arrTextsRotation[index] = rotationAngle
            }
        }
        print(arrTextsRotation)
        print("-==-=-==-=-=-=-=-==-=-=-=-")
    }
    
    func labelViewDidEndEditing(label: JLStickerLabelView, rotationAngle: CGFloat) {
    }
    
    func rotationValue() {
        printContent("ROOOO")
    }
    
    func showFontToolbar() {
        self.selectedStickerView?.showEditingHandlers = false
        showHideFontToolbar(isShow: true)
    }
    
    func hideFontToolbar() {
        showHideFontToolbar(isShow: false)
    }
    
    func removeLabel(label: JLStickerLabelView) {
        for (index,item) in self.viewCenter.labels.enumerated() {
            if (item as! JLStickerLabelView) == label {
                self.arrTextsRotation.remove(at: index)
                self.viewCenter.labels.remove(item)
            }
        }
        self.showHideFontToolbar(isShow: false)
    }
}

extension DesignPhotoBoothVC: StickerViewDelegate {
    func stickerViewDidBeginMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
        print("stickerViewDidBeginMoving")
    }
    
    func stickerViewDidChangeMoving(_ stickerView: StickerView) {
        self.selectedStickerView = stickerView
        print("stickerViewDidChangeMoving")
    }
    
    func stickerViewDidEndMoving(_ stickerView: StickerView) {
        print("stickerViewDidEndMoving")
        print("Frame: \(stickerView.frame)")
        
        if stickerView.tag == 1000 {
            self.backgroundImageFrame = stickerView.frame
        } else {
            if let index = arrStickers.firstIndex(where: {$0 == stickerView}) {
                self.arrStickersFrame[index] = stickerView.frame
            }
            
            self.arrangeViews(stickerView: stickerView)
        }
    }
    
    func stickerViewDidBeginRotating(_ stickerView: StickerView) {
        print("stickerViewDidBeginRotating")

    }
    
    func stickerViewDidChangeRotating(_ stickerView: StickerView) {}
    
    func stickerViewDidEndRotating(_ stickerView: StickerView) {
        print("=--=-=-=-===-=-=-==-===-=--=-=")
        print("stickerViewDidEndRotating")
        print("Current Rotation: \(stickerView.currentRotation)")
        if stickerView.tag == 1000 {
            self.backgroundImageRotate = stickerView.currentRotation
            self.backgroundImageScaleBound = stickerView.currentScale
        } else {
            if let index = arrStickers.firstIndex(where: {$0 == stickerView}) {
                arrStickersRotation[index] = stickerView.currentRotation
                arrStickersScale[index] = stickerView.currentScale ?? .zero
            }
        }
        print("=--=-=-=-===-=-=-==-===-=--=-=")
    }
    
    func stickerViewDidClose(_ stickerView: StickerView) {
        print("stickerViewDidClose")
        currentBackgroundImage = nil
        
        //.. Remove Sticker from Array
        if let index = self.arrStickers.firstIndex(where: {$0 == stickerView}) {
            self.arrStickers.remove(at: index)
            self.arrStickersFrame.remove(at: index)
            self.arrStickersRotation.remove(at: index)
            self.arrStickersScale.remove(at: index)
        }
        
    }
    
    func stickerViewDidTap(_ stickerView: StickerView) {
        print("stickerViewDidTap")
        
        //.. Remove focus from text
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()

        if stickerView.tag == 1000 {
            //.. Background Sticker.
            selectedStickerView?.showEditingHandlers = false
            stickerView.showEditingHandlers = true
        } else {
            selectedStickerView = stickerView
            stickerView.showEditingHandlers = true
            if let view = viewCenter.viewWithTag(1000) as? StickerView {
                view.showEditingHandlers = false
            }
            self.arrangeViews(stickerView: stickerView)
            
        }
    }
    
    func arrangeViews(stickerView: StickerView) {
        if let index = self.arrStickers.firstIndex(where: {$0 == stickerView}) {
            self.arrStickers = rearrange(array: arrStickers, fromIndex: index, toIndex: arrStickers.count - 1)
            self.arrStickersFrame = rearrange(array: arrStickersFrame, fromIndex: index, toIndex: arrStickersFrame.count - 1)
            self.arrStickersScale = rearrange(array: arrStickersScale, fromIndex: index, toIndex: arrStickersScale.count - 1)
            self.arrStickersRotation = rearrange(array: arrStickersRotation, fromIndex: index, toIndex: arrStickersRotation.count - 1)
        }
    }
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        return arr
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
    
    private func deleteBackgroundImageIfExists() {
        
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if fileName.lowercased() == "layout_\(layout?.id ?? 0)_background_image.jpg" {
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
