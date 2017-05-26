//
//  HRProgressButton.swift
//  ProgressButton
//
//  Created by hayashi311 on 5/14/17.
//  Copyright © 2017 hayashi311. All rights reserved.
//

import UIKit

public struct HRProgressButtonStyle {
    public let height: CGFloat
    public let minimumWidth: CGFloat
    public let horizontalPadding: CGFloat
    public let radius: CGFloat
    public let normalColor: UIColor
    public let highlightedColor: UIColor
    public let disabledColor: UIColor
    public let loadingColor: UIColor
    public let progressColor: UIColor
    
    public init(height: CGFloat,
                minimumWidth: CGFloat,
                horizontalPadding: CGFloat,
                radius: CGFloat,
                normalColor: UIColor,
                highlightedColor: UIColor,
                disabledColor: UIColor,
                loadingColor: UIColor,
                progressColor: UIColor) {
        self.height = height
        self.minimumWidth = minimumWidth
        self.horizontalPadding = horizontalPadding
        self.radius = radius
        self.normalColor = normalColor
        self.highlightedColor = highlightedColor
        self.disabledColor = disabledColor
        self.loadingColor = loadingColor
        self.progressColor = progressColor
    }
}

public protocol HRProgressButtonDefaultStyle {
    var defaultStyle: HRProgressButtonStyle { get }
}

extension HRProgressButtonDefaultStyle {
    public var defaultStyle: HRProgressButtonStyle {
        return HRProgressButtonStyle(height: 44, minimumWidth: 100, horizontalPadding: 26, radius: 22,
                                    normalColor: UIColor(red: 0.2, green: 0.29, blue: 0.37, alpha: 1.0),
                                    highlightedColor: UIColor(red: 0.17, green: 0.24, blue: 0.31, alpha: 1.0),
                                    disabledColor: UIColor(red: 0.58, green: 0.65, blue: 0.65, alpha: 1.0),
                                    loadingColor: UIColor(red: 0.58, green: 0.65, blue: 0.65, alpha: 1.0),
                                    progressColor: UIColor(red: 0.2, green: 0.29, blue: 0.37, alpha: 1.0))
    }
}

@IBDesignable
public class HRProgressButton: UIControl, HRProgressButtonDefaultStyle {
    
    private let containerView = UIView()
    private let backgroundLayer = CALayer()
    private let progressLayer = CALayer()
    private let indicator = HRIndicatorView()
    
    private let label = UILabel()
    
    private var _style: HRProgressButtonStyle?
    public var style: HRProgressButtonStyle {
        get {
            guard let s = _style else {
                _style = defaultStyle
                return defaultStyle
            }
            return s
        }
        set {
            _style = newValue
            backgroundLayer.cornerRadius = newValue.radius
            updateStyle(animation: false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        style = defaultStyle
        containerView.backgroundColor = .clear
        containerView.isUserInteractionEnabled = false
        backgroundLayer.cornerRadius = style.radius
        backgroundLayer.masksToBounds = true
        backgroundLayer.addSublayer(progressLayer)
        containerView.layer.addSublayer(backgroundLayer)
        containerView.addSubview(label)
        addSubview(containerView)
        addSubview(indicator)
        updateStyle(animation: false)
    }
    
    deinit {
        progress?.removeObserver(self, forKeyPath: "fractionCompleted")
    }
    
    override public func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        containerView.frame = bounds
        backgroundLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        indicator.frame = bounds
        label.frame = bounds
        CATransaction.commit()
    }
    
    override public var intrinsicContentSize: CGSize {
        let labelSize = label.sizeThatFits(CGSize(width: 1000, height: style.height))
        let width = max(labelSize.width + style.horizontalPadding * 2, style.minimumWidth)
        return CGSize(width: width, height: style.height)
    }
    
    override public var isHighlighted: Bool {
        didSet {
            updateStyle(animation: true)
        }
    }
    
    public var isLoading: Bool = false {
        didSet {
            updateStyle(animation: true)
            
            if isLoading {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                    self?.label.alpha = 0
                    self?.label.transform = CGAffineTransform(translationX: 0, y: -6)
                }, completion: { [weak self] (_) in
                    self?.indicator.startAnimating()
                })
            } else {
                progress = nil
                indicator.stopAnimating() {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                        self?.label.alpha = 1
                        self?.label.transform = CGAffineTransform.identity
                    }, completion: nil)
                }
            }
        }
    }
    
    private(set) var progress: Progress? {
        didSet {
            progress?.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)

            updateProgress()
            
            if let o = oldValue {
                o.removeObserver(self, forKeyPath: "fractionCompleted")
            }
        }
    }
    
    public func setIsLoading(with progress: Progress) {
        self.isLoading = true
        self.progress = progress
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey : Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted" {
            updateProgress()
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            updateStyle(animation: true)
        }
    }
    
    private var titles: [UInt: NSAttributedString] = [:]
    
    public func setAttributedTitle(_ title: NSAttributedString?, for state: UIControlState) {
        if let t = title {
            titles[state.rawValue] = t
        } else {
            titles.removeValue(forKey: state.rawValue)
        }
        
        if self.state == state {
            label.attributedText = title
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
            updateStyle(animation: false)
        }
    }
    
    func attributedTitle(for state: UIControlState) -> NSAttributedString? {
        return titles[state.rawValue] ?? titles[UIControlState.normal.rawValue]
    }
    
    func updateStyle(animation: Bool = true) {
        CATransaction.begin()
        if animation {
            CATransaction.setAnimationDuration(0.16)
        } else {
            CATransaction.setDisableActions(true)
        }
        let backgroundColor: UIColor
        let scale: CGFloat
        let size: CGSize?
        if isLoading {
            backgroundColor = style.loadingColor
            scale = 1
            size = CGSize(width: 70, height: style.height)
        } else if state.contains(.highlighted) {
            backgroundColor = style.highlightedColor
            scale = 0.96
            size = nil
        } else if state.contains(.disabled) {
            backgroundColor = style.disabledColor
            scale = 1
            size = nil
        } else {
            backgroundColor = style.normalColor
            scale = 1
            size = nil
        }
        
        backgroundLayer.backgroundColor = backgroundColor.cgColor
        containerView.layer.transform = CATransform3DMakeScale(scale, scale, scale)
        backgroundLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        if let s = size {
            backgroundLayer.bounds = CGRect(origin: CGPoint.zero, size: s)
        } else {
            backgroundLayer.bounds = bounds
        }
        progressLayer.backgroundColor = style.progressColor.cgColor
        label.attributedText = attributedTitle(for: state)
        CATransaction.commit()
    }
    
    func updateProgress() {
        CATransaction.begin()
        
        if let p = progress?.fractionCompleted {
            CATransaction.setAnimationDuration(0.16)
            progressLayer.opacity = 1
            progressLayer.frame = CGRect(x: 0, y: 0,
                                         width: backgroundLayer.bounds.width * CGFloat(p),
                                         height: backgroundLayer.bounds.height)
            if p >= 1 {
                backgroundLayer.backgroundColor = style.progressColor.cgColor
            }
        } else {
            CATransaction.setDisableActions(true)
            progressLayer.opacity = 0
            progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
        }
        CATransaction.commit()
    }
}
