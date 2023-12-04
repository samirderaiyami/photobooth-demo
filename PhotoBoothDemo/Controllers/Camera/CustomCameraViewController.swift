//
//  CustomCameraVC.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 15/11/23.
//

import UIKit
import AVFoundation

class CustomCameraVC: UIViewController {
    
    
    //MARK: - IBOutlets
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var testImageView: UIImageView!
    @IBOutlet weak var noOfLayouts: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewPhotoBox: UIView!
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var viewCenter: JLStickerImageView!
    @IBOutlet weak var heightOfHeader: NSLayoutConstraint!

    //MARK: - Variables
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var windowRect: CGRect!
    var windowRect1: CGRect {
        return CGRect(x: 0, y: 0, width: 393, height: 618)
    }
    var isFrontCamera = false
    var currentPhotoCount = 0
    
    var arrPhotoboothImages: [UIImage] = []
    var arrPhotoboothImageViews: [UIView] = []
    
    var cameraOverlayView: CameraOverlayView!
    
    var layout: Layout?
    var currentView: UIView!
    var currentImageView: UIImageView?

    var imagePicker: UIImagePickerController!
    var isAllowTakePhoto = true

    //MARK: - ViewLife-Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        noOfLayouts.text = "1 / \(layout?.noOfViews ?? 1)"
        
        self.setupLayoutViews()
        self.setupCaptureSession()
        heightOfHeader.constant = 100
        self.viewCenter.isHidden = true
        setupLayoutData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCameraWithOverlay(holeHeight: arrPhotoboothImageViews[0].frame.height, holeWidth: arrPhotoboothImageViews[0].frame.width)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the preview layer fits the camera view bounds.
        previewLayer?.frame = cameraView.bounds
    }

    
}

//MARK: - IBAction Methods
extension CustomCameraVC {
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
    
}

//MARK: - Custom Methods
extension CustomCameraVC {
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
                for (_,item) in layout.steakers.enumerated() {
                    showSticker(sticker: item)
                }
            }
            
            //.. BACKGROUND IMAGE
            self.showBackgroundImage()
        }
        
        self.viewCenter.currentlyEditingLabel?.hideEditingHandlers()
    }
    
    func showSticker(sticker: Sticker) {
        
        let stickerView = self.createNormalSticker(image: UIImage(named: "smile_1")!, stickerFrame: sticker.location)
        self.viewCenter.addSubview(stickerView)
        
        //.. ROTATION
        stickerView.transform = CGAffineTransform(rotationAngle: CGFloat(sticker.rotationAngle))
        
        //.. SCALE
        if sticker.scale != .zero {
            stickerView.bounds = sticker.scale
            stickerView.setNeedsDisplay()
        }
        
    }
    
    func showBackgroundImage() {
        
        //.. Background Image
        if let image = loadImage(nameOfImage: "\(self.layout?.id ?? 0)"), let layout = self.layout {
            
            //.. Restore variables
            
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
        stickerView.setImage(deleteImage!, forHandler: StickerViewHandler.close)
        stickerView.setImage(resizeImage!, forHandler: StickerViewHandler.rotate)
        stickerView.showEditingHandlers = false
        stickerView.outlineBorderColor = .clear
        stickerView.clipsToBounds = true
        stickerView.tag = 999
        return stickerView
    }
    
    func addLabel(textModel: Text?) {
        
        if let textModel {
            
            viewCenter.addLabel(textModel: textModel)
            
            self.viewCenter.textColor = colorWithHexString(hexString: textModel.color)
            
            viewCenter.currentlyEditingLabel.closeView!.image = deleteImage
            viewCenter.currentlyEditingLabel.rotateView?.image = resizeImage
            viewCenter.currentlyEditingLabel.closeView?.layer.cornerRadius = 9
            viewCenter.currentlyEditingLabel.rotateView?.layer.cornerRadius = 9
        }
        
    }
    
    func removeOverlayIfExists() {
        let overlayTag = 1001 // Arbitrary unique tag
        if let existingOverlay = view.viewWithTag(overlayTag) {
            existingOverlay.removeFromSuperview()
        }
    }
    
    func setupCameraWithOverlay(holeHeight: CGFloat, holeWidth: CGFloat) {
        cameraOverlayView = CameraOverlayView(holeHeight: holeHeight, holeWidth: holeWidth)
        
        let overlayHeight = (UIScreen.main.bounds.height - 129.0 - 183.0) + 30
        cameraOverlayView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: overlayHeight)
        
        cameraOverlayView.tag = 1001
        cameraView.addSubview(cameraOverlayView)
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
    
    @objc func takePhoto() {
        if isAllowTakePhoto {
            let settings = AVCapturePhotoSettings()
            stillImageOutput.capturePhoto(with: settings, delegate: self)
            isAllowTakePhoto = false
        }
    }

}

//MARK: - AVCapturePhotoCaptureDelegate Methods
extension CustomCameraVC: AVCapturePhotoCaptureDelegate {
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
            
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            
            if var croppedImage = image.cropToRect(rect: CGRect(x: 0, y: 0, width: self.cameraOverlayView.holeWidth, height: self.cameraOverlayView.holeHeight)) {
                
                //.. Save Taken Photo to the Photos
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

                
                if isFrontCamera {
                    croppedImage = self.flipImageHorizontally(croppedImage)!
                }
                
                arrPhotoboothImages.append(croppedImage)
                self.collectionView.reloadData()
                
                for (index,item) in arrPhotoboothImages.enumerated() {
                    let currentView = arrPhotoboothImageViews[index]
                    let imageView = UIImageView()
                    imageView.image = item
                    imageView.frame = currentView.bounds
                    imageView.contentMode = .scaleToFill
                    currentView.addSubview(imageView)
                }
                

                //.. Update overlay
                removeOverlayIfExists()
                                
                if arrPhotoboothImages.count == layout?.noOfViews ?? 1 {
                    print("Finished!")
                    
                    DispatchQueue.main.async {
                        print("This is run on the main queue, after the previous code in outer block")
                        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "YourPhotoVC") as! YourPhotoVC
                        self.viewCenter.isHidden = false
                        vc.finalImage = self.viewCenter.image()
                        self.viewCenter.isHidden = true
                        vc.layout = self.layout
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                     
                } else {
                    isAllowTakePhoto = true
                    noOfLayouts.text = "\(arrPhotoboothImages.count + 1) / \(layout?.noOfViews ?? 1)"
                    setupCameraWithOverlay(holeHeight: arrPhotoboothImageViews[arrPhotoboothImages.count].frame.height, holeWidth: arrPhotoboothImageViews[arrPhotoboothImages.count].frame.width)
                }
                
            }
             
        }
         
    }
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout Methods
extension CustomCameraVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

//MARK: - Local Directory Methods
extension CustomCameraVC {
    
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
//MARK: - GENERATE LAYOUTS
extension CustomCameraVC {
    func addConstraintAndSubViews<T: UIView>(myCustomView: T) {
        myCustomView.translatesAutoresizingMaskIntoConstraints = false
        myCustomView.tag = 120
        myCustomView.isUserInteractionEnabled = false
        
        // Add the subview to the cell
        self.viewCenter.addSubview(myCustomView)
        // Constraints for myCustomView to match cell size
        NSLayoutConstraint.activate([
            myCustomView.topAnchor.constraint(equalTo: self.viewCenter.topAnchor),
            myCustomView.bottomAnchor.constraint(equalTo: self.viewCenter.bottomAnchor),
            myCustomView.leadingAnchor.constraint(equalTo: self.viewCenter.leadingAnchor),
            myCustomView.trailingAnchor.constraint(equalTo: self.viewCenter.trailingAnchor)
        ])
        
        for view in myCustomView.subviews {
            arrPhotoboothImageViews.append(view)
        }
        
    }
    
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

}
