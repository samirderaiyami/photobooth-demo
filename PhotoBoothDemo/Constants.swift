//
//  Constants.swift
//  PhotoBoothDemo
//
//  Created by Mac-0006 on 21/11/23.
//

import Foundation
import UIKit


struct Constraint: Codable {
    var constant: CGFloat
    var isRelative: Bool
    var relativeViewID: String?
}

struct ViewLayout: Codable {
    var id: String
    var imageName: String
    var leading: Constraint
    var trailing: Constraint
    var top: Constraint
    var bottom: Constraint?
    var height: CGFloat?
}

struct ViewsLayout: Codable {
    var views: [ViewLayout]
}

let dynamicLayoutOne = ViewsLayout(views: [
    ViewLayout(
        id: "view1",
        imageName: "box",
        leading: Constraint(constant:5, isRelative: false),
        trailing: Constraint(constant: -5, isRelative: false),
        top: Constraint(constant: 20, isRelative: false),
        height: 100
    )
])

let dynamicLayoutTwo = ViewsLayout(views: [
    ViewLayout(
        id: "view1",
        imageName: "box",
        leading: Constraint(constant: 20, isRelative: false),
        trailing: Constraint(constant: -20, isRelative: false),
        top: Constraint(constant: 20, isRelative: false),
        height: 100
    ),
    ViewLayout(
        id: "view2",
        imageName: "box1",
        leading: Constraint(constant: 20, isRelative: false),
        trailing: Constraint(constant: -20, isRelative: false),
        top: Constraint(constant: 15, isRelative: false),
        height: 100
    )
])

let dynamicLayoutThree = ViewsLayout(views: [
    ViewLayout(
        id: "view1",
        imageName: "box",
        leading: Constraint(constant: 20, isRelative: false),
        trailing: Constraint(constant: -20, isRelative: false),
        top: Constraint(constant: 20, isRelative: false),
        bottom: Constraint(constant: 20, isRelative: false)
    )
])

var arrDynamicLayouts: [ViewsLayout] = [dynamicLayoutOne, dynamicLayoutTwo, dynamicLayoutThree]


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

func captureUltraHighQualityImage(from view: UIView, manualScale: CGFloat = 4.0) -> UIImage? {
    let rendererFormat = UIGraphicsImageRendererFormat.default()
    rendererFormat.opaque = view.isOpaque // Set to true if the view is opaque
    rendererFormat.scale = manualScale // Manually set a high scale value
    
    let renderer = UIGraphicsImageRenderer(bounds: view.bounds, format: rendererFormat)
    
    let capturedImage = renderer.image { context in
        view.layer.render(in: context.cgContext)
    }
    
    return capturedImage
    }


struct CUserDefaultsKey {
    static var userSavedVideos = "userSavedVideos"
}
