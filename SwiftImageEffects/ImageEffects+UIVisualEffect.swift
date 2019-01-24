//
//  ImageEffects+UIVisualEffect.swift
//  Pods
//
//  Created by Antoine Cœur on 07/08/2017.
//
//

import UIKit

#if swift(>=4.2)
#else
// Swift 4.0 compatibility
extension UIBlurEffect {
    public typealias Style = UIBlurEffectStyle
}
#endif

/// experimental
public struct ImageEffects {
    @available(*, unavailable) private init() {}
    
    /*
    UIBlurEffectStyleExtraLight,
    UIBlurEffectStyleLight,
    UIBlurEffectStyleDark,
    UIBlurEffectStyleExtraDark __TVOS_AVAILABLE(10_0) __IOS_PROHIBITED __WATCHOS_PROHIBITED,
    UIBlurEffectStyleRegular NS_ENUM_AVAILABLE_IOS(10_0), // Adapts to user interface style
    UIBlurEffectStyleProminent NS_ENUM_AVAILABLE_IOS(10_0), // Adapts to user interface style
    */
    
    public static func blurWithUIKit(style: UIBlurEffect.Style) -> UIView {
        let blurEffect = UIBlurEffect(style: style)
        let alphaView = UIVisualEffectView(effect: blurEffect)
        return alphaView
    }
    
    public static func vibrancyWithUIKit(style: UIBlurEffect.Style) -> UIView {
        let blurEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: style))
        let alphaView = UIVisualEffectView(effect: blurEffect)
        return alphaView
    }
}
