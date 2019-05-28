//
//  FormButtonBigCell.swift
//
//  Created by Renquan Wang on 2018-02-02.
//  Copyright © 2018 Renquan Wang. All rights reserved.
//

import UIKit

open class FormButtonBigCell: FormBaseCell {
    @IBOutlet weak var button: UIButton!
    override open func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data)
        button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 30.0, bottom: 0.0, right: 30.0)
        button.setTitle(self.dataOj?.title ?? "", for: UIControl.State.normal)
        self.dataOj?.cellHeight = 96
        button.alpha = self.dataOj?.enable == true ? CGFloat(1.0) : CGFloat(0.5)
        button.isEnabled = self.dataOj?.enable == true
        self.button.layer.cornerRadius = 5
        self.button.layer.masksToBounds = true
        if self.dataOj?.options?["color"] == "red" {
            self.button.backgroundColor = UIColor.red
        } else {
            if (self.dataOj?.options?["color"] == "gray") {
                self.button.backgroundColor = UIColor.gray
            } else {
                self.button.backgroundColor = FormConfigs.bigButtonTextColor
            }
        }
    }

    @IBAction open func onBtnClick(_ sender: Any) {
        let _ = self.triggerValueChange(value: "")
    }
    override open func focus() -> CellRequest {
        //let ret = self.triggerValueChange(value: "")
        return CellRequest.none
    }
}

