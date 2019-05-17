//
//  FormTextCell.swift
//
//  Created by Renquan Wang on 2017-08-24.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormTextCell: FormBaseCell, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data)
        self.selectionStyle = .none
        textView.text = self.dataOj?.title
        if let ops = self.dataOj?.options, let value = ops["type"], value == "edit" {
            self.dataOj?.cellHeight = 44 * 5
            textView.isEditable = true
            textView.isSelectable = true
            textView.backgroundColor = FormConfigs.editBackgroundColor
            textView.delegate = self
        } else {
            textView.isSelectable = false
            textView.isEditable = false
            let sizeToFit: CGSize = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 32, height: 10000))
            self.dataOj?.cellHeight = sizeToFit.height + 17
            textView.backgroundColor = UIColor.clear
            textView.delegate = nil
        }
        self.updateTextViewColor()
    }

    func updateTextViewColor() {
        if (textView.isEditable == true) {
            if (self.dataOj?.validate() == false) {
                textView.layer.borderColor = FormConfigs.nokColor.cgColor
                textView.layer.borderWidth = 2.0
            } else {
                textView.layer.borderColor = UIColor.clear.cgColor
                textView.layer.borderWidth = 0
            }
        } else {
            textView.layer.borderColor = UIColor.clear.cgColor
            textView.layer.borderWidth = 0
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let _ = self.triggerValueChange(value: textView.text)
        self.dataOj?.title = textView.text
        self.updateTextViewColor()
    }
}
