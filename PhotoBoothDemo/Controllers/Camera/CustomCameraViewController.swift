//
//  CustomCameraViewController.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 15/11/23.
//

import UIKit
import AVFoundation

class CustomCameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var windowRect: CGRect!
    var windowRect1: CGRect {
        return CGRect(x: 0, y: 0, width: 393, height: 618)
    }
    var isFrontCamera = false
    //    var mainLayoutModel: MainLayoutModel?
    var currentPhotoCount = 0
    var indexSelected = 0
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var width: NSLayoutConstraint!
    
    var arrPhotoboothImages: [UIImage] = []
    var arrPhotoboothImageViews: [UIView] = []
    
    var cameraOverlayView: CameraOverlayView!
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var noOfLayouts: UILabel!
    
    var layout: Layout?
    var currentView: UIView!
    var currentImageView: UIImageView?
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewPhotoBox: UIView!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var viewCenter: JLStickerImageView!
    @IBOutlet weak var heightOfHeader: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        noOfLayouts.text = "1 / \(layout?.noOfViews ?? 1)"
        addViews()
        self.setupCaptureSession()
        setupCameraWithOverlay(holeHeight: arrPhotoboothImageViews[0].frame.height, holeWidth: arrPhotoboothImageViews[0].frame.width)
        heightOfHeader.constant = 100
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.viewCenter.isHidden = false
        })
        
        setupLayoutData()

    }
    
    
    func removeOverlayIfExists() {
        let overlayTag = 1001 // Arbitrary unique tag
        if let existingOverlay = view.viewWithTag(overlayTag) {
            existingOverlay.removeFromSuperview()
        }
    }
    
    
    func setupCameraWithOverlay(holeHeight: CGFloat, holeWidth: CGFloat) {
        cameraOverlayView = CameraOverlayView(holeHeight: holeHeight, holeWidth: holeWidth)
        cameraOverlayView.frame = cameraView.bounds // Assuming 'view' is your camera view
        cameraOverlayView.tag = 1001
        cameraView.addSubview(cameraOverlayView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func addViews() {
        
        // Create the custom view
        if layout?.indexSelected == 0 {
            let myCustomView: _4x6Layout1 = _4x6Layout1.fromNib()
            // Add the subview to the cell
            
            myCustomView.translatesAutoresizingMaskIntoConstraints = false
            
            myCustomView.tag = 120
            
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
    
    @IBAction func btnGo(sender: UIButton) {
        if arrPhotoboothImages.count < self.layout?.noOfViews ?? 0 {
            takePhoto()
        }
    }
    
    @IBAction func flipCameraButtonTapped(_ sender: UIButton) {
        flipCamera()
    }
    @IBAction func btnBack(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func takePhoto() {
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the preview layer fits the camera view bounds.
        previewLayer?.frame = cameraView.bounds
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        // Start configuration
        captureSession.beginConfiguration()
        
        captureSession.sessionPreset = .photo
        stillImageOutput = AVCapturePhotoOutput()
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera),
              captureSession.canAddInput(input),
              captureSession.canAddOutput(stillImageOutput) else {
            return
        }
        
        captureSession.addInput(input)
        captureSession.addOutput(stillImageOutput)
        
        // Commit configuration
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
        setupLivePreview()
    }
    
    func setupLivePreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = cameraView.bounds
        cameraView.layer.addSublayer(previewLayer)
    }
    
    func flipCamera() {
        // Assuming 'captureSession' is your AVCaptureSession instance
        guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first else {
            return
        }
        
        captureSession.beginConfiguration()
        
        captureSession.removeInput(currentCameraInput)
        
        let newCameraDevice: AVCaptureDevice
        if let input = currentCameraInput as? AVCaptureDeviceInput, input.device.position == .back {
            newCameraDevice = cameraWithPosition(.front) ?? AVCaptureDevice.default(for: .video)!
        } else {
            newCameraDevice = cameraWithPosition(.back) ?? AVCaptureDevice.default(for: .video)!
        }
        
        var newVideoInput: AVCaptureDeviceInput?
        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCameraDevice)
        } catch {
            print(error)
        }
        
        if let newVideoInput = newVideoInput, captureSession.canAddInput(newVideoInput) {
            captureSession.addInput(newVideoInput)
        }
        
        captureSession.commitConfiguration()
        isFrontCamera = !isFrontCamera
    }
    
    func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        return devices.first(where: { $0.position == position })
    }
    func flipImageHorizontally(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Flip the image
        context.translateBy(x: image.size.width, y: 0)
        context.scaleBy(x: -1, y: 1)
        
        image.draw(at: .zero)
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
    
    
}

extension UIBezierPath {
    func scaled(to size: CGSize) -> UIBezierPath {
        let scaleX = size.width / UIScreen.main.bounds.width
        let scaleY = size.height / UIScreen.main.bounds.height
        let scaledPath = self.copy() as! UIBezierPath
        scaledPath.apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
        return scaledPath
    }
}

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    
    func extractImage(from originalImage: UIImage, using overlayView: CameraOverlayView) -> UIImage? {
        let imageSize = originalImage.size
        let imageScaleFactor = min(imageSize.width / overlayView.holeWidth, imageSize.height / overlayView.holeHeight)
        let overlayPath = overlayView.holePath(scaledBy: imageScaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, originalImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Clip the context to the overlay path
        overlayPath.addClip()
        
        // Draw the image in the current context
        originalImage.draw(at: CGPoint(x: 0, y: 0))
        
        // Extract the image
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }
    
    func cropImage(_ originalImage: UIImage, toFrame cropFrame: CGRect, inImageView imageView: UIImageView) -> UIImage? {
        guard let cgImage = originalImage.cgImage else { return nil }
        
        // Calculate the scale factor based on the content mode
        let imageViewRatio = imageView.bounds.size.width / imageView.bounds.size.height
        let imageRatio = originalImage.size.width / originalImage.size.height
        let isImageWider = imageRatio > imageViewRatio
        
        let scaleFactor: CGFloat
        if imageView.contentMode == .scaleAspectFill {
            scaleFactor = isImageWider ? originalImage.size.height / imageView.bounds.size.height
            : originalImage.size.width / imageView.bounds.size.width
        } else { // .scaleAspectFit or others
            scaleFactor = isImageWider ? originalImage.size.width / imageView.bounds.size.width
            : originalImage.size.height / imageView.bounds.size.height
        }
        
        // Convert cropFrame to image's scale
        let scaledCropFrame = CGRect(
            x: cropFrame.origin.x * scaleFactor,
            y: cropFrame.origin.y * scaleFactor,
            width: cropFrame.size.width * scaleFactor,
            height: (cropFrame.size.height * scaleFactor) - 50
        )
        
        // Perform cropping
        guard let croppedCgImage = cgImage.cropping(to: scaledCropFrame) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            
            if var croppedImage = image.cropToRect(rect: CGRect(x: 0, y: 0, width: self.cameraOverlayView.holeWidth, height: self.cameraOverlayView.holeHeight)) {
                
                if isFrontCamera {
                    croppedImage = self.flipImageHorizontally(croppedImage)!
                }
                
                arrPhotoboothImages.append(croppedImage)
                
                
                self.collectionView.reloadData()
                
                for (index,item) in arrPhotoboothImages.enumerated() {
                    let currentView = arrPhotoboothImageViews[index]
                    let imageView = UIImageView()
                    imageView.backgroundColor = UIColor.red
                    imageView.image = item
                    imageView.frame = currentView.bounds
                    imageView.contentMode = .scaleToFill
                    currentView.addSubview(imageView)
                }
                
                noOfLayouts.text = "\(arrPhotoboothImages.count + 1) / \(layout?.noOfViews ?? 1)"
                
                //.. Update overlay
                removeOverlayIfExists()
                
                if arrPhotoboothImages.count == layout?.noOfViews ?? 0 {
                    print("Finished!")
                    
                    if let ultraHighQualityImage = captureUltraHighQualityImage(from: viewCenter, manualScale: 10.0) {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YourPhotoVC") as! YourPhotoVC
                            vc.finalImage = ultraHighQualityImage//self.viewCenter.asImage()
                            vc.layout = self.layout
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                    }
                } else {
                    setupCameraWithOverlay(holeHeight: arrPhotoboothImageViews[arrPhotoboothImages.count].frame.height, holeWidth: arrPhotoboothImageViews[arrPhotoboothImages.count].frame.width)
                }
            }
        }
    }
    
    func extractImage(from capturedImage: UIImage, withOverlayFrame overlayFrame: CGRect, inCameraView cameraView: UIView) -> UIImage? {
        let imageSize = capturedImage.size
        let cameraViewSize = cameraView.bounds.size
        
        // Calculate the scale factors
        let widthScale = imageSize.width / cameraViewSize.width
        let heightScale = imageSize.height / cameraViewSize.height
        
        // Calculate the scaled overlay frame
        let scaledOverlayFrame = CGRect(
            x: overlayFrame.origin.x * widthScale,
            y: overlayFrame.origin.y * heightScale,
            width: overlayFrame.size.width * widthScale,
            height: overlayFrame.size.height * heightScale
        )
        
        guard let croppedCgImage = capturedImage.cgImage?.cropping(to: scaledOverlayFrame) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCgImage, scale: capturedImage.scale, orientation: capturedImage.imageOrientation)
    }
    
}


extension CustomCameraViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        return arrPhotoboothImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraPhotoCollCell", for: indexPath) as! CameraPhotoCollCell
        cell.imgPhoto.image = arrPhotoboothImages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 114)
    }
    
}
extension UIImage {
    func cropToRect(rect: CGRect) -> UIImage? {
        var scale = rect.width / self.size.width
        scale = self.size.height * scale < rect.height ? rect.height/self.size.height : scale
        
        let croppedImsize = CGSize(width:rect.width/scale, height:rect.height/scale)
        let croppedImrect = CGRect(origin: CGPoint(x: (self.size.width-croppedImsize.width)/2.0,
                                                   y: (self.size.height-croppedImsize.height)/2.0),
                                   size: croppedImsize)
        UIGraphicsBeginImageContextWithOptions(croppedImsize, true, 0)
        self.draw(at: CGPoint(x:-croppedImrect.origin.x, y:-croppedImrect.origin.y))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
}

extension CustomCameraViewController {
    
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
        
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
    }

    func addSticker(frame: CGRect, name: String, rotationAngle: CGFloat = 0.0, scale: CGRect? = nil) {
        
        let testImage = UIImageView.init(frame: frame)
        testImage.image = UIImage(named: "smile_1")
        testImage.contentMode = .scaleAspectFit
        let stickerView3 = StickerView.init(contentView: testImage)
        stickerView3.frame = frame
        stickerView3.setImage(deleteImage!, forHandler: StickerViewHandler.close)
        stickerView3.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
        stickerView3.showEditingHandlers = false
        stickerView3.outlineBorderColor = .clear
        stickerView3.tag = 999
        
        self.viewCenter.addSubview(stickerView3)
        
        stickerView3.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
                
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
    
    func adBackgroundImage() {
        
        //.. Background Image
        if let image = loadImage(nameOfImage: "\(self.layout?.id ?? 0)") {
            let testImage = UIImageView.init(frame: self.viewCenter.bounds)
            testImage.image = image
            testImage.contentMode = .scaleAspectFill
            let stickerView3 = StickerView.init(contentView: testImage)
            stickerView3.frame = layout?.layoutBackgroundFrame ?? .zero
            stickerView3.setImage(deleteImage!, forHandler: StickerViewHandler.close)
            stickerView3.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
            stickerView3.setImage(resizeImage!, forHandler: StickerViewHandler.flip)
            stickerView3.showEditingHandlers = false
            stickerView3.outlineBorderColor = .clear
            stickerView3.clipsToBounds = true
            stickerView3.tag = 1000
            
            stickerView3.transform = CGAffineTransform(rotationAngle: CGFloat(layout?.layoutBackgroundRotate ?? 0.0))
            
            if layout?.layoutBackgroundScale != nil {
                stickerView3.bounds = layout!.layoutBackgroundScale!
                stickerView3.setNeedsDisplay()
            }
            
            if let view1 = self.viewCenter.viewWithTag(120) {
                if let viewToRemove = view1.viewWithTag(1000) {
                    viewToRemove.removeFromSuperview()
                }
                view1.insertSubview(stickerView3, at: 0)
            }
        }
        
    }

}
extension CustomCameraViewController {
    
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
    
}
