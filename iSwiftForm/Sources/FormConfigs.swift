//
//  Constants.swift
//
//  Created by Renquan Wang on 2017-08-22.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

let libIdentifier = "app.mso.iSwiftForm"

class FormConfigs {
    static func UIColorFromRGB(hex6: UInt32, alpha: CGFloat = 1) -> UIColor {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat(hex6 & 0x0000FF) / divisor
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    static let primaryColor: UIColor = UIColorFromRGB(hex6: 0x005aa0)
    static let selectedColor: UIColor = UIColorFromRGB(hex6: 0x024172)
    static let editBackgroundColor: UIColor = UIColorFromRGB(hex6: 0xd0d0d0)
    static let defaultSelectedColor: UIColor = UIColorFromRGB(hex6: 0xd9d9d9)
    static let tableViewSectionColor: UIColor = UIColorFromRGB(hex6: 0xF0F0F5)
    static let inProgressGreenColor: UIColor = UIColorFromRGB(hex6: 0x0C8E11)
    static let okColor: UIColor = UIColorFromRGB(hex6: 0x1A931F)
    static let nokColor: UIColor = UIColorFromRGB(hex6: 0xE25859)
    static let okLightGreenColor: UIColor = UIColorFromRGB(hex6: 0xd1e9d2)
    static let okLightGreenColorFocused: UIColor = UIColorFromRGB(hex6: 0xbedfbf)
    static let isIPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    static let headerAlignment: NSTextAlignment = NSTextAlignment.center
    static let headerPadding: UIEdgeInsets? = UIEdgeInsets(top: 18, left: 18, bottom: 0, right: 0)
    static let bundle: Bundle? = libIdentifier == Bundle.main.bundleIdentifier ? nil : Bundle(identifier: libIdentifier)
    static let fillCellWithOKColor: Bool = false
}
