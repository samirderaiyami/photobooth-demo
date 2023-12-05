//
//  stickerView.swift
//  stickerTextView
//
//  Created by AppcanoLLC on 16/4/20.
//  Copyright © AppcanoLLC. All rights reserved.
//

import UIKit

protocol JLStickerImageViewDelegate {
    func showFontToolbar()
    func hideFontToolbar()
    func labelViewDidEndEditing(label: JLStickerLabelView, rotationAngle: CGFloat)
    func labelViewChangeEditing(label: JLStickerLabelView, rotationAngle: CGFloat)
    func removeLabel(label: JLStickerLabelView)
}

public class JLStickerImageView: UIImageView, UIGestureRecognizerDelegate {
    public var currentlyEditingLabel: JLStickerLabelView!
    public var labels: NSMutableArray!
    public var renderedView: UIView!
    var delegate: JLStickerImageViewDelegate?
    
    public lazy var tapOutsideGestureRecognizer: UITapGestureRecognizer! = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(JLStickerImageView.tapOutside))
        tapGesture.delegate = self
        return tapGesture
        
    }()

    //MARK: -
    //MARK: init
    
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
        labels = []
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        labels = []
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        labels = []
    }
    
}

//MARK: -
//MARK: Functions
extension JLStickerImageView {
    public func addDefaultLabel(defaultFrame: CGRect) {
        
        let labelView = JLStickerLabelView(frame: defaultFrame)
        labelView.delegate = self

        labelView.labelTextView.backgroundColor = .clear
        labelView.labelTextView.text = "ENTER TEXT"
        labelView.labelTextView.fontName = "HelveticaNeue"
        labelView.labelTextView.fontSize = 20
        labelView.labelTextView.tintColor = .black
        labelView.labelTextView.textColor = .black

        self.addSubview(labelView)
        
        self.currentlyEditingLabel = labelView
        
        self.adjustsWidthToFillItsContens(self.currentlyEditingLabel, labelView: self.currentlyEditingLabel.labelTextView)

        self.labels.add(labelView)
        
        self.addGestureRecognizer(tapOutsideGestureRecognizer)
        
    }
    
    func addLabel(textModel: Text) {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }
        let labelView = JLStickerLabelView(frame: textModel.location)
        labelView.delegate = self
        
        labelView.labelTextView.backgroundColor = .clear
        labelView.labelTextView.text = textModel.text
        labelView.labelTextView.fontName = textModel.font
        labelView.labelTextView.fontSize = textModel.size
        labelView.labelTextView.textColor = colorWithHexString(hexString: textModel.color)

        self.addSubview(labelView)
        self.currentlyEditingLabel = labelView

        self.adjustsWidthToFillItsContens(self.currentlyEditingLabel, labelView: self.currentlyEditingLabel.labelTextView)
        
        self.labels.add(labelView)
        self.addGestureRecognizer(tapOutsideGestureRecognizer)
        
        labelView.transform = CGAffineTransform(rotationAngle: textModel.rotationAngle)

    }
    
    public func renderTextOnView(_ view: UIView) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return img
    }
    
    public func limitImageViewToSuperView() {
        if self.superview == nil {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = true
        let imageSize = self.image?.size
        let aspectRatio = imageSize!.width / imageSize!.height
        
        let w: CGFloat = (imageSize?.width)!
        let h: CGFloat = (imageSize?.height)!
        
        if w > h {
            self.bounds.size.width = self.superview!.bounds.size.width
            self.bounds.size.height = self.superview!.bounds.size.width / aspectRatio
        }else {
            self.bounds.size.height = self.superview!.bounds.size.height
            self.bounds.size.width = self.superview!.bounds.size.height * aspectRatio
        }
        
    }
    
}

//MARK-
//MARK: Gesture
extension JLStickerImageView {
    @objc func tapOutside() {
        if let _: JLStickerLabelView = currentlyEditingLabel {
            currentlyEditingLabel.hideEditingHandlers()
        }
        
    }
}

//MARK-
//MARK: stickerViewDelegate
extension JLStickerImageView: JLStickerLabelViewDelegate {
    public func labelViewDidBeginEditing(_ label: JLStickerLabelView) {
        //labels.removeObject(label)
        print("labelViewDidBeginEditing")
    }
    
    public func labelViewDidClose(_ label: JLStickerLabelView) {
        delegate?.removeLabel(label: label)
        print("labelViewDidClose")
    }
    
    public func labelViewDidShowEditingHandles(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
        print("labelViewDidShowEditingHandles")

    }
    
    public func labelViewDidHideEditingHandles(_ label: JLStickerLabelView) {
        currentlyEditingLabel = nil
        self.delegate?.hideFontToolbar()
        
        print("labelViewDidHideEditingHandles")

    }
    
    public func labelViewDidStartEditing(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
        print("labelViewDidStartEditing")

    }
    
    public func labelViewDidChangeEditing(_ label: JLStickerLabelView) {
        print("labelViewDidChangeEditing")
//        print(label.rotationAngle)
        //delegate?.labelViewChangeEditing(label: label, rotationAngle: label.rotationAngle)

    }
    
    public func labelViewDidEndEditing(_ label: JLStickerLabelView) {
//        print("labelViewDidEndEditing")
//        print(label.rotationAngle)
//        delegate?.labelViewDidEndEditing(label: label, rotationAngle: label.rotationAngle)
    }
    
    public func labelViewDidSelected(_ label: JLStickerLabelView) {
        print("labelViewDidEndEditing")

        for labelItem in labels {
            if let label: JLStickerLabelView = labelItem as? JLStickerLabelView {
                label.hideEditingHandlers()
            }
        }
        label.showEditingHandles()
        self.delegate?.showFontToolbar()
    }
    
    public func labelViewDidChangeRotation(_ label: JLStickerLabelView, currentRotation: CGFloat) {
        delegate?.labelViewChangeEditing(label: label, rotationAngle: currentRotation)
    }
    
}

//MARK: -
//MARK: Set propeties

extension JLStickerImageView: adjustFontSizeToFillRectProtocol {
    
    public enum textShadowPropterties {
        case offSet(CGSize)
        case color(UIColor)
        case blurRadius(CGFloat)
    }
    
    public var fontName: String! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.fontName = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel, labelView: currentlyEditingLabel.labelTextView)
                
            }
        }
        get {
            return self.currentlyEditingLabel.labelTextView.fontName
        }
    }
    
    public var textColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.foregroundColor = newValue
            }
        }
        get {
            return self.currentlyEditingLabel.labelTextView.foregroundColor
        }
    }
    
    public var textAlpha: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.textAlpha = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.textAlpha
        }
    }
    
    public var fontSize: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.fontSize = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.fontSize
        }
    }
    
    //MARK: -
    //MARK: text Format
    
    public var textAlignment: NSTextAlignment! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.alignment = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.alignment
        }
    }
    
    public var lineSpacing: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.lineSpacing = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel, labelView: currentlyEditingLabel.labelTextView)
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.lineSpacing
            
        }
    }
    
    //MARK: -
    //MARK: text Background
    
    public var textBackgroundColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.textBackgroundColor = newValue
            }
            
        }
        
        get {
            return self.currentlyEditingLabel.labelTextView.textBackgroundColor
        }
    }
    
    public var textBackgroundAlpha: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.textBackgroundAlpha = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.textBackgroundAlpha
            
        }
    }
    
    //MARK: -
    //MARK: text shadow
    
    public var textShadowOffset: CGSize! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.textShadowOffset = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.shadow?.shadowOffset
        }
    }
    
    public var textShadowColor: UIColor! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.textShadowColor = newValue
            }
            
        }
        get {
            return (self.currentlyEditingLabel.labelTextView.shadow?.shadowColor) as? UIColor
        }
    }
    
    public var textShadowBlur: CGFloat! {
        set {
            if self.currentlyEditingLabel != nil {
                self.currentlyEditingLabel.labelTextView.textShadowBlur = newValue
            }
            
        }
        get {
            return self.currentlyEditingLabel.labelTextView.shadow?.shadowBlurRadius
        }
    }
    
    
}
