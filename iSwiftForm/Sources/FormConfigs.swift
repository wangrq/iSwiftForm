//
//  Constants.swift
//
//  Created by Renquan Wang on 2017-08-22.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

let libIdentifier = "app.mso.iSwiftForm"

open class FormConfigs {
    static func UIColorFromRGB(hex6: UInt32, alpha: CGFloat = 1) -> UIColor {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat(hex6 & 0x0000FF) / divisor
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    static let isIPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    static let bundle: Bundle? = libIdentifier == Bundle.main.bundleIdentifier ? nil : Bundle(identifier: libIdentifier)

    // form view controller background color
    public static var tableViewSectionColor: UIColor = UIColorFromRGB(hex6: 0xF0F0F5)
    // form cell title color (focused)
    public static var selectedColor: UIColor = UIColorFromRGB(hex6: 0x024172)
    // form cell background color (focused)
    public static var defaultSelectedColor: UIColor = UIColorFromRGB(hex6: 0xd9d9d9)
    // default text color of Button
    public static var buttonTextColor: UIColor = UIColorFromRGB(hex6: 0x005aa0)
    // default text color of Big Button
    public static var bigButtonTextColor: UIColor = UIColorFromRGB(hex6: 0x0C8E11)

    // used in editable Text, the background color of the edit text
    public static var editBackgroundColor: UIColor = UIColorFromRGB(hex6: 0xd0d0d0)
    // used in editable Text, the border color if the edit text isn't validated
    public static var editBorderNokColor: UIColor = UIColorFromRGB(hex6: 0xE25859)

    // should the validated cell be filled with a background color
    public static var fillCellWithOKColor: Bool = true
    // the background color of the validated cell (only show it if fillCellWithOKColor = true)
    public static var okLightGreenColor: UIColor = UIColorFromRGB(hex6: 0xd1e9d2)
    // the background color of the focused validated cell (only show it if fillCellWithOKColor = true)
    public static var okLightGreenColorFocused: UIColor = UIColorFromRGB(hex6: 0xbedfbf)

    // form group header text alignment
    public static var headerAlignment: NSTextAlignment = NSTextAlignment.center
    // form group header text paddings
    public static var headerPadding: UIEdgeInsets? = UIEdgeInsets(top: 18, left: 18, bottom: 0, right: 0)

}
