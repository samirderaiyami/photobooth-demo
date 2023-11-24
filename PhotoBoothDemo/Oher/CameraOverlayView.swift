//
//  OO.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 24/11/23.
//

import Foundation
import UIKit
//class CameraOverlayView: UIView {
//    
//    var holeHeight: CGFloat = 100 // Default height, you can change this dynamically
//    private let holeCornerRadius: CGFloat = 10.0
//    var isShape: Bool = true // Variable to decide whether to draw shape or hole
//    var shapeName = "" // Variable to decide whether to draw shape or hole
//    var imageRect: CGRect?
//    
//    // Added property to store the hole's frame
//    var holeRect: CGRect {
//        // Hardcoded values for debugging
//        return CGRect(x: 50, y: 100, width: 200, height: 200)
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.backgroundColor = UIColor.clear
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        
//        if isShape {
//            drawShape(in: rect)
//        } else {
//            drawHole(in: rect)
//        }
//        
//    }
//    
//    func drawHole(in rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        
//        // Create a semi-transparent black background
//        context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
//        context.fill(rect)
//        
//        // Define the hole rectangle with rounded corners
//        let holeRect = CGRect(x: 0, y: rect.midY - holeHeight/2, width: UIScreen.main.bounds.width, height: holeHeight)
//        let holePath = UIBezierPath(roundedRect: holeRect, cornerRadius: holeCornerRadius)
//        
//        // Add the hole path and clip the context
//        context.addPath(holePath.cgPath)
//        context.clip()
//        
//        // Clear the hole area
//        context.setBlendMode(.clear)
//        context.fill(holeRect)
//        
//    }
//    
//    private func drawShape(in rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext(), let shapeImage = UIImage(named: shapeName) else { return }
//        
//        // Correct the image orientation
//        // Set the semi-transparent background
//        context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
//        context.fill(rect)
//        
//        //        // Scaling factor
//        //        let scaleFactor: CGFloat = 1.5
//        //
//        //        // Calculate the new size of the image
//        //        let scaledWidth = shapeImage.size.width * scaleFactor
//        //        let scaledHeight = shapeImage.size.height * scaleFactor
//        //
//        //        // Calculate the frame for the scaled image
//        //        let imageRect = CGRect(x: rect.midX - scaledWidth / 2, y: rect.midY - scaledHeight / 2, width: scaledWidth, height: scaledHeight)
//        
//        // Define new fixed size
//        let newWidth: CGFloat = 380  // New width
//        let newHeight: CGFloat = 380 // New height
//        
//        // Calculate the frame for the image with the new size
//        self.imageRect = CGRect(x: rect.midX - newWidth / 2, y: rect.midY - newHeight / 2, width: newWidth, height: newHeight)
//        
//        // Create a mask from the image and clip the context
//        context.clip(to: self.imageRect!, mask: shapeImage.cgImage!)
//        
//        // Clear the area within the mask to create the hole
//        context.setBlendMode(.clear)
//        context.fill(self.imageRect!)
//        
//    }
//}

class CameraOverlayView: UIView {
    
    var holeHeight: CGFloat
    var holeWidth: CGFloat
    var holeCornerRadius: CGFloat = 5.0
    
    func holePath(scaledBy scaleFactor: CGFloat) -> UIBezierPath {
        let scaledHoleWidth = holeWidth * scaleFactor
        let scaledHoleHeight = holeHeight * scaleFactor
        let holeRect = CGRect(
            x: (bounds.width - scaledHoleWidth) / 2,
            y: (bounds.height - scaledHoleHeight) / 2,
            width: scaledHoleWidth,
            height: scaledHoleHeight
        )
        return UIBezierPath(roundedRect: holeRect, cornerRadius: holeCornerRadius * scaleFactor)
    }

    
    init(holeHeight: CGFloat, holeWidth: CGFloat) {
        self.holeHeight = holeHeight
        self.holeWidth = holeWidth
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawHole(in: rect)
    }

    
    func drawHole(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Create a semi-transparent black background
        context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
        context.fill(rect)
        
        // Calculate scaled size
        let scale = min(rect.width / holeWidth, rect.height / holeHeight)
        let scaledHoleWidth = holeWidth * scale
        let scaledHoleHeight = holeHeight * scale
        
        // Define the scaled hole rectangle
        let holeRect = CGRect(
            x: rect.midX - scaledHoleWidth / 2,
            y: rect.midY - scaledHoleHeight / 2,
            width: scaledHoleWidth,
            height: scaledHoleHeight
        )
        let holePath = UIBezierPath(roundedRect: holeRect, cornerRadius: holeCornerRadius * scale)
        
        // Add the hole path and clip the context
        context.addPath(holePath.cgPath)
        context.clip()
        
        // Clear the hole area
        context.setBlendMode(.clear)
        context.fill(holeRect)

    }
    
  
}
