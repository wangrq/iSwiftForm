//
//  FormDateTimeCell.swift
//
//  Created by Renquan Wang on 2017-08-24.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormDateTimeCell: FormBaseCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    var datePicker: UIDatePicker = UIDatePicker(frame: CGRect.zero)
    var saveButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
    var isExpanded: Bool = false
    var isUsingTodayAsMaxDate = false
    let df: DateFormatter = DateFormatter()

    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data, self.titleLabel)
        self.valueLabel.text = data.value
        df.dateFormat = "yyyy-MM-dd HH:mm"
        self.datePicker.date = getInputDateTime(data)
        self.datePicker.isHidden = true
        let now = Date()
        self.datePicker.maximumDate = now
        if let ops = self.dataOj?.options, let futureDaysStr = ops["futureDays"], let futureDays = Int(futureDaysStr) {
            self.datePicker.maximumDate = Calendar.current.date(byAdding: .day, value: futureDays, to: now) ?? now
        }
        self.datePicker.addTarget(self, action: #selector(onValueChange(_:)), for: UIControl.Event.valueChanged)
        self.saveButton.setBackgroundImage(UIImage(named: "btn_primary", in: FormConfigs.bundle, compatibleWith: nil), for: UIControl.State.normal)
        self.saveButton.setTitle("Done", for: UIControl.State.normal)
        self.saveButton.titleLabel?.textColor = UIColor.white
        self.saveButton.addTarget(self, action: #selector(FormDateTimeCell.selectOK), for: UIControl.Event.touchUpInside)
        if let ops = self.dataOj?.options, let type = ops["mode"] {
            switch type {
            case "date":
                self.datePicker.datePickerMode = .date
            case "time":
                self.datePicker.datePickerMode = .time
                self.datePicker.maximumDate = nil
            default:
                self.datePicker.datePickerMode = .dateAndTime
            }
        } else {
            self.datePicker.datePickerMode = .dateAndTime
        }
        if let ops = self.dataOj?.options, let baseDayStr = ops["oneDayAfter"] {
            // oneDayAfter format: "2018-03-03 12:12"
            let baseDayConv = df.date(from: baseDayStr)
            if let baseDay = baseDayConv, baseDay < now {
                self.datePicker.minimumDate = baseDay
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: baseDay)!
                if (tomorrow < now) {
                    self.datePicker.maximumDate = tomorrow
                }
            }
        }
        self.isUsingTodayAsMaxDate = self.datePicker.maximumDate == now
    }

    func getInputDateTime(_ data: FormData) -> Date {
        var initDate: Date? = nil;
        if (data.value.count > 0) {
            let dateStr = data.value
            if let ops = self.dataOj?.options, let type = ops["mode"] {
                switch type {
                case "date":
                    initDate = df.date(from: dateStr + " 00:00")
                case "time":
                    initDate = df.date(from: "2018-01-01 " + dateStr)
                default:
                    initDate = df.date(from: dateStr)
                }
            } else {
                initDate = df.date(from: dateStr)
            }
        } else {
            if let ops = self.dataOj?.options {
                if (ops["defaultValue"] != nil) {
                    let dateStr = ops["defaultValue"]!
                    if let type = ops["mode"] {
                        switch type {
                        case "date":
                            initDate = df.date(from: dateStr + " 00:00")
                        case "time":
                            initDate = df.date(from: "2018-01-01 " + dateStr)
                        default:
                            initDate = df.date(from: dateStr)
                        }
                    } else {
                        initDate = df.date(from: dateStr)
                    }
                }
            }
        }
        return initDate ?? Date()
    }

    @objc func selectOK() {
        let _ = self.focus()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let _ = self.cellCallbackDelegate?.cellCallback(CellRequest.updateHeight)
        }
    }
    override func focus() -> CellRequest {
        checkUpdateMaxTime()
        if (self.isExpanded) {
            return self.blur()
        } else {
            if (self.dataOj!.value == "" || self.dataOj!.value.count < 2) {
                self.onValueChange(datePicker)
            }
            self.dataOj?.cellHeight = 278 + 44 // default Date Picker height: 216
            self.updateConstraintsForTableView(height: 278)
            self.titleLabel.textColor = FormConfigs.selectedColor
            self.isExpanded = true
            self.datePicker.isHidden = false
        }
        return CellRequest.updateHeight
    }

    override func blur() -> CellRequest {
        if (self.isExpanded) {
            self.dataOj?.cellHeight = 44
            self.updateConstraintsForTableView(height: 0)
            self.titleLabel.textColor = UIColor.black
            self.isExpanded = false
            self.datePicker.isHidden = true
            return CellRequest.updateHeight
        }
        return CellRequest.none
    }

    override func reselectCell() {
        if self.isExpanded {
            self.datePicker.isHidden = false
        }
    }

    func updateConstraintsForTableView(height: CGFloat) {
        if height > 1 {
            datePicker.frame = CGRect(x: 0, y: 45, width: self.frame.size.width, height: height - 38 - 16)
            self.contentView.addSubview(datePicker)
            // button height: 38 + 16(margin)
            saveButton.frame = CGRect(x: self.frame.size.width - 128, y: 45 + height - 38 - 8, width: 120, height: 38)
            self.contentView.addSubview(saveButton)
        } else {
            datePicker.removeFromSuperview()
            saveButton.removeFromSuperview()
        }
        //self.datePicker.layoutIfNeeded()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if (newWindow != nil) {
            NotificationCenter.default.addObserver(self, selector: #selector(FormDateTimeCell.checkUpdateMaxTime), name: Notification.Name(rawValue: "MINUTE_CHANGE_NOTIFICATION"), object: nil)
        }
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if (self.window == nil) {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "MINUTE_CHANGE_NOTIFICATION"), object: nil)
        }
    }
    @objc func checkUpdateMaxTime() {
        if (self.isUsingTodayAsMaxDate) {
            DispatchQueue.main.async {
                self.datePicker.maximumDate = Date();
            }
        }
    }

    @objc func onValueChange(_ sender: UIDatePicker) {
        checkUpdateMaxTime()
        let str = self.getValueStr(from: sender)
        self.dataOj?.value = str
        self.valueLabel.text = self.dataOj?.value
        let _ = self.triggerValueChange(value: str, titleLabel: self.titleLabel)
    }

    func getValueStr(from: UIDatePicker) -> String {
        let rawStr = df.string(from: from.date)
        var str = rawStr
        if let ops = self.dataOj?.options, let type = ops["mode"] {
            switch type {
            case "date":
                let endIndex = str.index(str.endIndex, offsetBy: -6)
                str = String(str[..<endIndex])
            case "time":
                let startIndex = str.index(str.endIndex, offsetBy: -5)
                str = String(str[startIndex...])
            default:
                break
            }
        }
        return str
    }
}
