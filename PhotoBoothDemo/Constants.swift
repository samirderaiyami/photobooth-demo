//
//  Constants.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 21/11/23.
//

import Foundation
import UIKit


extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

func captureUltraHighQualityImage(from view: UIView, manualScale: CGFloat = 2.0) -> UIImage? {
    autoreleasepool {
        let reducedSize = CGRect(origin: .zero, size: CGSize(width: view.bounds.width / 2, height: view.bounds.height / 2))
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.opaque = view.isOpaque
        rendererFormat.scale = manualScale
        rendererFormat.prefersExtendedRange = false // Use standard color depth
        
        let renderer = UIGraphicsImageRenderer(bounds: reducedSize, format: rendererFormat)
        
        let capturedImage = renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
        
        return capturedImage
    }
}



struct CUserDefaultsKey {
    static var userSavedVideos = "userSavedVideos"
}

func documentDirectoryPath() -> URL? {
    let path = FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)
    return path.first
}


let deleteImage = UIImage(named: "btn_delete")
let resizeImage = UIImage(named: "btn_resize")

