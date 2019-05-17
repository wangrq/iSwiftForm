//
//  FormButtonCell.swift
//
//  Created by Renquan Wang on 2017-08-31.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormButtonCell: FormBaseCell {
    @IBOutlet weak var titleLabel: UILabel!
    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data)
        titleLabel.text = self.dataOj?.title
        titleLabel.alpha = self.dataOj?.enable ==  true ? CGFloat(1.0) : CGFloat(0.5)
        if let ops = self.dataOj?.options, let value = ops["style"], value == "delete" {
            self.titleLabel.textColor = UIColor.red
        } else {
            self.titleLabel.textColor = FormConfigs.primaryColor
        }
    }

    override func focus() -> CellRequest {
        let _ = self.triggerValueChange(value: "")
        return CellRequest.deselect
    }
}
