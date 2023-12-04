//
//  OO.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 24/11/23.
//

import Foundation
import UIKit

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
