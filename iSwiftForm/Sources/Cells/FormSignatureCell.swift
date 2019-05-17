//
//  FormSignatureCell.swift
//
//  Created by Renquan Wang on 2017-08-24.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormSignatureCell: FormBaseCell, SignatureViewDelegate {
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var signatureView: SignatureView!
    @IBOutlet weak var signBG: UIImageView!
    @IBOutlet weak var signatureContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signatureHeightConstranit: NSLayoutConstraint!

    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data, self.titleLabel)
        let cellHeight: CGFloat = FormConfigs.isIPad ? 352 : 252
        self.dataOj?.cellHeight = cellHeight
        signatureHeightConstranit.constant = cellHeight - 112
        signatureContainerView.layoutIfNeeded()
        self.selectionStyle = .none
        self.signatureView.delegate = self
        self.signatureView.clearCanvas()
        self.clearButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        self.lockButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        self.clearButton.setTitle("Clear", for: .normal)
        var contentEmpty = true;
        if let valueData = self.dataOj?.value, valueData.count > 1 {
            self.signatureView.originalImage = UIImage(data: Data(base64Encoded: valueData, options: .ignoreUnknownCharacters)!)
            self.disableDraw(false)
            contentEmpty = false;
            self.signBG.image = UIImage(named: "sign_bg_ok", in: FormConfigs.bundle, compatibleWith: nil)
        } else {
            self.signatureView.originalImage = nil
            self.enableDraw()
        }
        if (self.dataOj?.enable == false) {
            self.lockButton.isEnabled = false
        } else {
            if let ops = self.dataOj?.options, let disableEdit = ops["disableEditIfNotEmpty"], disableEdit == "true", contentEmpty == false {
                self.lockButton.isEnabled = false;
            } else {
                self.lockButton.isEnabled = true
            }
        }
    }

    @IBAction func onLockButtonClicked(_ sender: UIButton) {
        if (sender.title(for: .normal) == "Save") {
            self.disableDraw()
        } else {
            self.enableDraw()
        }

    }
    func enableDraw() {
        self.lockButton.setTitle("Save", for: .normal)
        self.clearButton.isHidden = false
        self.signBG.image = UIImage(named: "sign_bg", in: FormConfigs.bundle, compatibleWith: nil)
        self.signatureView.drawingEnabled = true
    }
    func disableDraw(_ save: Bool = true) {
        if (self.signatureView.signaturePresent == false) {
            //
        }
        self.lockButton.setTitle("Edit Signature", for: .normal)
        self.clearButton.isHidden = true
        self.signatureView.drawingEnabled = false
        if (save) {
            self.signatureView.captureSignature()
        }
    }
    @IBAction func onClearButtonClicked(_ sender: UIButton) {
        signatureView.clearCanvas()
        let _ = self.triggerValueChange(value: "", titleLabel: self.titleLabel)
    }
    func SignatureViewDidCaptureSignature(view: SignatureView, signature: Signature?) {
        if signature != nil {
            // User add new stoke on the view
            let pngdata = signature!.image.pngData()
            if let data = pngdata?.base64EncodedString(options: .lineLength64Characters) {
                let _ = self.triggerValueChange(value: data, titleLabel: self.titleLabel)
            }
        } else if view.originalImage != nil {
            // User didn't add anyting on the view
            //
        } else {
            // User clicked CLEAR button
            let _ = self.triggerValueChange(value: "", titleLabel: self.titleLabel)
        }
        if (self.dataOj!.value.count > 0) {
            self.signBG.image = UIImage(named: "sign_bg_ok", in: FormConfigs.bundle, compatibleWith: nil)
            if let ops = self.dataOj?.options, let disableEdit = ops["disableEditIfNotEmpty"], disableEdit == "true" {
                self.lockButton.isEnabled = false;
            }
        }
    }
}
