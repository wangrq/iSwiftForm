//
//  FormSingleChoice.swift
//
//  Created by Renquan Wang on 2017-08-22.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormSegmentedControl: FormBaseCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chooseControl: UISegmentedControl!

    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data, self.titleLabel)
        self.selectionStyle = .none
        self.chooseControl.selectedSegmentIndex = UISegmentedControl.noSegment
        for (index, value) in data.textSuggestions!.enumerated() {
            if (index >= self.chooseControl.numberOfSegments) {
                self.chooseControl.insertSegment(withTitle: value, at: index, animated: false)
            } else {
                self.chooseControl.setTitle(value, forSegmentAt: index)
            }
            self.chooseControl.setEnabled(true, forSegmentAt: index)
            if (value == self.dataOj?.value) {
                self.chooseControl.selectedSegmentIndex = index
            }
        }
        if let number = self.dataOj?.textSuggestions?.count {
            while self.chooseControl.numberOfSegments > number {
                self.chooseControl.removeSegment(at: self.chooseControl.numberOfSegments - 1, animated: false)
            }
        }
        if let disabledSegementStr = self.dataOj?.options?["disabledSegement"] {
            if let disabledSegement = Int(disabledSegementStr) {
                self.chooseControl.setEnabled(false, forSegmentAt: disabledSegement)
            }
        }
        self.chooseControl.isEnabled = self.dataOj!.enable
        self.titleLabel.alpha = self.dataOj!.enable ? CGFloat(1.0) : CGFloat(0.5)
        self.chooseControl.addTarget(self, action: #selector(onValueChange(_:)), for: .valueChanged)
    }

    @objc func onValueChange(_ sender: UISegmentedControl) {
        let valueIndex = sender.selectedSegmentIndex
        let _ = self.triggerValueChange(value: self.dataOj?.textSuggestions?[valueIndex] ?? "", titleLabel: self.titleLabel)
    }
}
