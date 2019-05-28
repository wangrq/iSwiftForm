//
//  FormInputCell
//
//  Created by Renquan Wang on 2017-08-21.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormInputCell: FormBaseCell {
    @IBOutlet weak var inputField: AutoCompleteTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func editBegin(_ sender: AutoCompleteTextField) {
        titleLabel.textColor = FormConfigs.selectedColor
        selectRow()
    }
    @IBAction func editEnd(_ sender: AutoCompleteTextField) {
        titleLabel.textColor = UIColor.black
        let _ = self.blur()
        let _ = self.triggerValueChange(value: self.inputField.text ?? "", titleLabel: self.titleLabel)
    }
    @IBAction func onEditChange(_ sender: UITextField) {
        let value = self.inputField.text ?? ""
        self.inputField.text = getNonBreakingSpaces(text: value)
        let _ = self.triggerValueChange(value: getNormalSpaces(text: value), titleLabel: self.titleLabel)
    }

    @IBAction func onPrimaryButtonClick(_ sender: UITextField) {
        if let tableView = self.cellCallbackDelegate, let parentView = tableView as? FormBaseController {
            parentView.keyboardNextButton()
        }
    }

    func getNonBreakingSpaces(text: String) -> String {
        return text.replacingOccurrences(of: " ", with: "\u{00a0}")
    }

    func getNormalSpaces(text: String) -> String {
        return text.replacingOccurrences(of: "\u{00a0}", with: " ")
    }

    func selectRow() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.isSelected {
                //self.containerTableView?.beginUpdates()
                //self.containerTableView?.endUpdates()
                return
            }
            if let tableView = self.containerTableView {
                if let previousRow = tableView.indexPathForSelectedRow {
                    let cell = tableView.cellForRow(at: previousRow) as? FormBaseCell
                    let ret = cell?.blur()
                    if ret == CellRequest.updateHeight {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
                let indexPath = tableView.indexPath(for: self)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                //tableView.beginUpdates()
                //tableView.reloadRows(at: [indexPath], with: .automatic)
                //tableView.endUpdates()
                //self.containerTableView?.delegate?.tableView!(self.containerTableView!, didSelectRowAt: indexPath!)
            }
        }
    }

    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data, self.titleLabel)
        self.inputField.text = getNonBreakingSpaces(text: data.value)
        self.inputField.placeholder = data.valuePlaceHolder ?? data.title
        //self.inputField.delegate = self
        if data.enable == false {
            self.inputField.isEnabled = false
            self.titleLabel.alpha = CGFloat(0.5)
            self.inputField.alpha = CGFloat(0.5)
        } else {
            self.inputField.isEnabled = true
            self.titleLabel.alpha = CGFloat(1.0)
            self.inputField.alpha = CGFloat(1.0)
            switch self.dataOj!.inputType {
            case .text:
                self.inputField.keyboardType = .alphabet
                self.inputField.autocapitalizationType = .sentences
            case .capWord:
                self.inputField.keyboardType = .alphabet
                self.inputField.autocapitalizationType = .words
            case .number:
                self.inputField.keyboardType = .numberPad
            case .phone:
                self.inputField.keyboardType = .phonePad
            case .email:
                self.inputField.keyboardType = .emailAddress
                self.inputField.autocapitalizationType = .none
                self.inputField.autocorrectionType = .no
            case .none:
                self.inputField.keyboardType = .alphabet
                self.inputField.autocapitalizationType = .none
            }
            if self.dataOj!.nextSection >= 0 {
                self.inputField.returnKeyType = .next
            } else {
                self.inputField.returnKeyType = .done
            }
        }
        self.inputField.font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.font = UIFont.systemFont(ofSize: 17)
        if let bold = self.dataOj?.options?["bold"], bold == "true" {
            self.inputField.font = UIFont.boldSystemFont(ofSize: 17)
            self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        }
    }

    override func focus() -> CellRequest {
        if self.inputField.isFirstResponder {
            let _ = self.blur()
        } else {
            self.inputField.becomeFirstResponder()
        }
        return CellRequest.none
    }

    override func blur() -> CellRequest {
        if self.inputField.isFirstResponder {
            self.inputField.resignFirstResponder()
        }
        return CellRequest.none
    }
}
