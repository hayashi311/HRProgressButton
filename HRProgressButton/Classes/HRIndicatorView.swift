//
//  HRIndicatorView.swift
//  ProgressButton
//
//  Created by hayashi311 on 5/16/17.
//  Copyright © 2017 hayashi311. All rights reserved.
//

import UIKit


class HRIndicatorView: UIView {
    
    private let repeatAnimationKey = "RepeatAnimationKey"
    private let repeatAnimation = CAAnimationGroup()
    
    private let replicatorLayer = CAReplicatorLayer()
    private let circleLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        isUserInteractionEnabled = false
        
        circleLayer.bounds = CGRect(x: 0, y: 0, width: 8, height: 8)
        circleLayer.position = CGPoint(x: 4, y: 5)
        circleLayer.backgroundColor = UIColor.white.cgColor
        circleLayer.cornerRadius = 4
        circleLayer.opacity = 0
        circleLayer.transform = CATransform3DMakeTranslation(0, 6, 0)
        replicatorLayer.addSublayer(circleLayer)
        replicatorLayer.instanceCount = 3
        let transform = CATransform3DMakeTranslation(14, 0, 0)
        replicatorLayer.instanceTransform = transform
        replicatorLayer.instanceDelay = 0.1
        layer.addSublayer(replicatorLayer)
        
        // repeat
        repeatAnimation.duration = 0.5
        repeatAnimation.autoreverses = true
        repeatAnimation.repeatCount = .infinity
        repeatAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let height = CABasicAnimation(keyPath: "bounds")
        height.toValue = CGRect(x: 0, y: 0, width: 8, height: 10)
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.toValue = 1
        
        repeatAnimation.animations = [height, opacity]
        
    }
    
    override func layoutSubviews() {
        replicatorLayer.bounds = CGRect(x: 0, y: 0, width: 38, height: 10)
        replicatorLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    func startAnimating() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        circleLayer.transform = CATransform3DIdentity
        circleLayer.opacity = 0.5
        CATransaction.setCompletionBlock { [weak self] in
            guard let s = self else { return }
            s.circleLayer.add(s.repeatAnimation, forKey: s.repeatAnimationKey)
        }
        CATransaction.commit()
    }
    
    func stopAnimating(_ complition: (() -> Void)? = nil) {
        CATransaction.begin()
        circleLayer.removeAnimation(forKey: repeatAnimationKey)
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        circleLayer.transform = CATransform3DMakeTranslation(0, 6, 0)
        circleLayer.opacity = 0
        
        if let c = complition {
            let additional = replicatorLayer.instanceDelay * CFTimeInterval(replicatorLayer.repeatCount)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + additional, execute: c)
        }
        
        CATransaction.commit()
    }
}
