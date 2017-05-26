//
//  HRTextStyle.swift
//  iOSDCJP2016
//
//  Created by hayashi311 on 6/9/16.
//  Copyright © 2016 hayashi311. All rights reserved.
//

import UIKit

public class HRTextStyle {

    public enum Weight {
        case Thin
        case Regular
        case Bold
        
        var fontWeight: CGFloat {
            get {
                switch self {
                case .Thin:
                    return UIFontWeightThin
                case .Regular:
                    return UIFontWeightRegular
                case .Bold:
                    return UIFontWeightBold
                }
            }
        }
    }
    
    let size: CGFloat
    var color: UIColor
    var textAlignment: NSTextAlignment
    var weight: Weight
    
    public init(size: CGFloat, color: UIColor, textAlignment: NSTextAlignment, weight: Weight) {
        self.size = size
        self.color = color
        self.textAlignment = textAlignment
        self.weight = weight
    }
    
    func buildAttributes() -> [String: AnyObject] {
        let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = textAlignment
        
        return [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: UIFont.systemFont(ofSize: size, weight: weight.fontWeight),
            NSParagraphStyleAttributeName: style,
        ]
    }
}

public extension NSAttributedString {
    public convenience init(string: String, style: HRTextStyle) {
        let attrs = style.buildAttributes()
        self.init(string: string, attributes: attrs)
    }
}
