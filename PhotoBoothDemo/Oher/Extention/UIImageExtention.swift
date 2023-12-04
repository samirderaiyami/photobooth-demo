//
//  UIImageExtention.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 04/12/23.
//

import UIKit

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
