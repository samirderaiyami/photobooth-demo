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
    @IBOutlet weak var viewCenter: UIView!
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
                    
                    layout?.images = []
                    for image in arrPhotoboothImages {
                        if let data = image.jpegData(compressionQuality: 0.5) {
                            layout?.images.append(data)
                        }
                    }
                    
                    
                    Layout.updateUserEditedVideos(VideoModel: layout!)
                    
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

