//
//  Extension+UIView.swift
//  PhotoBoothDemo
//
//  Created by Mindinventory on 05/12/23.
//

import Foundation
import UIKit

enum Nib: String {
    case _4x6Layout1
    case _4x6Layout2
    
    var name: String {
        return rawValue
    }
}

class NibLoader {
    static func loadView<T: UIView>(_ viewType: T.Type, fromNib nib: Nib, owner: Any? = nil, viewToAdd: UIView? = nil, subViews: (([UIView]) -> Void)? = nil) {
        let bundle = Bundle.main
        let nibName = nib.name
        let nibObjects = bundle.loadNibNamed(nibName, owner: owner, options: nil)
        
        if let views = nibObjects as? [T], let view = views.first {
            if let subViewToAdd = viewToAdd {
                view.translatesAutoresizingMaskIntoConstraints = false
                
                // Add the subview to the cell
                view.tag = 120
                subViewToAdd.addSubview(view)
                
                // Constraints for myCustomView to match cell size
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: subViewToAdd.topAnchor),
                    view.bottomAnchor.constraint(equalTo: subViewToAdd.bottomAnchor),
                    view.leadingAnchor.constraint(equalTo: subViewToAdd.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: subViewToAdd.trailingAnchor)
                ])
                
                subViews?(view.subviews)
            }

        } else {
            fatalError("Could not load view from nib: \(nibName)")
        }
    }
}
