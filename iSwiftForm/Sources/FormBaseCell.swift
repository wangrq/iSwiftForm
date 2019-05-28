//
//  FormBaseCell.swift
//
//  Created by Renquan Wang on 2017-08-22.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

public enum CellRequest: Int {
    case none = 0, deselect, updateHeight
}

protocol CellCallback {
    func cellCallback(_: CellRequest?) -> String?
}

protocol FormValueChangeDelegate {
    func onValueChange(_: FormData, _: String) -> Bool
}

open class FormBaseCell: UITableViewCell {
    var dataOj: FormData?
    var cellCallbackDelegate: CellCallback?
    var valueChangeDelegate: FormValueChangeDelegate?
    weak var containerTableView: UITableView?
    var selfIndexPath: IndexPath?
    var fillOKColor: Bool? = nil

    open func focus() -> CellRequest {
        return CellRequest.deselect
    }
    open func blur() -> CellRequest {
        return CellRequest.none
    }
    open func setup(data: FormData, _ label: UILabel? = nil) {
        self.dataOj = data
        self.valueChangeDelegate = self.dataOj?.valueChangeCallback
        if let titleLabel = label {
            self.updateLabelText(titleLabel)
        }
    }
    open func triggerValueChange(value: String, titleLabel: UILabel? = nil) -> Bool {
        self.dataOj?.value = value
        let ret = self.valueChangeDelegate?.onValueChange(self.dataOj!, value)
        if let label = titleLabel {
            self.updateLabelText(label)
        }
        return ret ?? false
    }
    open func updateLabelText(_ titleLabel: UILabel) {
        let title = "\(self.dataOj!.title):"
        if let validator = self.dataOj?.validator {
            let imageAttachment =  NSTextAttachment()
            if validator.test(value: self.dataOj?.value) {
                imageAttachment.image = UIImage(named:"form_ic_check", in: FormConfigs.bundle, compatibleWith: nil)
            } else {
                imageAttachment.image = UIImage(named:"form_star_mark", in: FormConfigs.bundle, compatibleWith: nil)
            }
            showImageIndicator(imageAttachment: imageAttachment, title: title, titleLabel: titleLabel)
        } else {
            titleLabel.text = title
        }
        self.fillCellWithColor(self.dataOj?.validate() ?? false)
    }

    func reselectCell() {}

    func showImageIndicator(imageAttachment: NSTextAttachment, title: String, titleLabel: UILabel) {
        let size = imageAttachment.image!.size
        let imageOffsetY:CGFloat = -6.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: size.width, height: size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        let  textAfterIcon = NSMutableAttributedString(string: title)
        completeText.append(textAfterIcon)
        titleLabel.attributedText = completeText;
    }

    func fillCellWithColor(_ fillOKColor: Bool) {
        if let indexPath = self.selfIndexPath, let tableView = self.containerTableView {
            if (self.fillOKColor == fillOKColor) {
                return;
            }
            self.fillOKColor = fillOKColor;
            let shouldFillColor = fillOKColor && self.dataOj?.type != CellType.Button.rawValue && self.dataOj?.type != CellType.ButtonBig.rawValue

            let cornerRadius: CGFloat = FormConfigs.isIPad ? 5 : 0
            self.backgroundColor = .clear
            let layer: CAShapeLayer = CAShapeLayer()
            let pathRef: CGMutablePath = CGMutablePath()
            let bounds: CGRect = self.bounds.insetBy(dx: 0, dy: 0)
            var addLine = false

            let lastRow = tableView.numberOfRows(inSection: indexPath.section) - 1

            if indexPath.row == 0 && indexPath.row == lastRow {
                pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
            } else if indexPath.row == 0 {
                pathRef.move(to: .init(x: bounds.minX, y: bounds.maxY))
                pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.minY), tangent2End: .init(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
                pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.minY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
                pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
                addLine = true
            } else if indexPath.row == lastRow {
                pathRef.move(to: .init(x: bounds.minX, y: bounds.minY))
                pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.maxY), tangent2End: .init(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
                pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.maxY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
                pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
            } else {
                pathRef.addRect(bounds)
                addLine = true
            }

            layer.path = pathRef
            layer.fillColor = shouldFillColor ? FormConfigs.okLightGreenColor.cgColor : UIColor(white: 1, alpha: 0.8).cgColor

            if addLine == true {
                let lineLayer = CALayer()
                let lineHeight = 1.0 / UIScreen.main.scale
                lineLayer.frame = CGRect(x: bounds.minX + 10, y: bounds.size.height - lineHeight, width: bounds.size.width - 10, height: lineHeight)
                lineLayer.backgroundColor = tableView.separatorColor?.cgColor
                layer.addSublayer(lineLayer)
            }

            let testView = UIView(frame: bounds)
            testView.layer.insertSublayer(layer, at: 0)
            testView.backgroundColor = .clear

            self.backgroundView = testView

            let bgColorView = UIView()
            bgColorView.backgroundColor = shouldFillColor ? FormConfigs.okLightGreenColorFocused : FormConfigs.defaultSelectedColor
            self.selectedBackgroundView = bgColorView
        }
    }
}
