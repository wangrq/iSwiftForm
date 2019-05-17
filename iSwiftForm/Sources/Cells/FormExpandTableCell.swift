//
//  FormExpandTableCell.swift
//
//  Created by Renquan Wang on 2017-08-22.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

class FormExpandTableCell: FormBaseCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var expandImage: UIImageView!
    var tableView: UITableView?
    var allowDeselect: Bool = false
    var isMultiple: Bool = false
    var isExpanded: Bool = false
    var indexed: Bool = false
    var indexKeys: [String] = []
    var groupedData: [String: [String]] = [:]
    var selectedItems: [String] = []
    override func setup(data: FormData, _ label: UILabel? = nil) {
        super.setup(data: data, self.titleLabel)
        self.valueLabel.text = data.value

        if data.enable == false {
            self.titleLabel.alpha = CGFloat(0.5)
            self.valueLabel.alpha = CGFloat(0.5)
        } else {
            self.titleLabel.alpha = CGFloat(1.0)
            self.valueLabel.alpha = CGFloat(1.0)
        }

        if let type = self.dataOj?.options?["type"], type == "multiple" {
            self.isMultiple = true
        } else {
            self.isMultiple = false
        }
        if let type = self.dataOj?.options?["allowDeselect"], type == "true" {
            self.allowDeselect = true
        } else {
            self.allowDeselect = false
        }
        if data.textSuggestions == nil {
            //data.choices = SuggestionEngine.getChoices(data.contentType, data.contentOptions)
        }
        if data.textSuggestions?.count == 0 {
            data.textSuggestions = [data.value]
        }
        self.indexed = data.textSuggestions!.count >= 20
        if (self.indexed == true) {
            self.groupedData = [:]
            self.indexKeys = []
            data.textSuggestions!.sort()
            var lastChracter = ""
            for choice in data.textSuggestions! {
                let firstCharacter: String = choice.first?.description ?? ""
                self.groupedData[firstCharacter] = self.groupedData[firstCharacter] ?? []
                self.groupedData[firstCharacter]?.append(choice)
                if (lastChracter != firstCharacter) {
                    lastChracter = firstCharacter
                    self.indexKeys.append(lastChracter)
                }
            }
        } else {
            //
        }
        self.selectedItems = []
        if self.isMultiple && self.dataOj!.value.count > 0 {
            self.selectedItems = self.dataOj!.value.components(separatedBy: ", ")
        }
    }

    func showTableView(_ height: CGFloat) {
        let offsetX: CGFloat = 8
        let offsetXRight: CGFloat = 24
        let offsetY: CGFloat = 44
        let frame = CGRect(x: offsetX, y: offsetY, width: self.frame.size.width - offsetX - offsetXRight, height: height)
        self.tableView = UITableView(frame: frame, style: self.indexed ? UITableView.Style.grouped : UITableView.Style.plain)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.allowsMultipleSelection = self.isMultiple
        self.tableView?.tableFooterView = UIView()
        self.contentView.addSubview(self.tableView!)
        //self.tableView?.reloadData()
    }

    func closeTableView() {
        self.tableView?.removeFromSuperview()
        self.tableView = nil
    }

    override func reselectCell() {
        if self.isExpanded {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.tableView?.reloadData()
                self.navToProperPosition()
            }
        }
    }

    override func focus() -> CellRequest {
        if self.dataOj!.enable == false {
            return .none
        }
        if (self.isExpanded) {
            let _ = self.blur()
        } else {
            let rowNumber = min(10, dataOj!.textSuggestions!.count)
            self.dataOj?.cellHeight = 44 * CGFloat(rowNumber) + 44 + 8
            DispatchQueue.main.async(execute: { () -> Void in
                self.showTableView(44 * CGFloat(rowNumber) + 8)
                self.navToProperPosition()
            })
            self.titleLabel.textColor = FormConfigs.selectedColor
            self.isExpanded = true
        }
        return CellRequest.updateHeight
    }

    override func blur() -> CellRequest {
        if (self.isExpanded) {
            self.dataOj?.cellHeight = 44
            self.closeTableView()
            self.titleLabel.textColor = UIColor.black
            self.isExpanded = false
            return CellRequest.updateHeight
        }
        return CellRequest.none
    }

    func navToProperPosition() {
        if (self.isMultiple == false && self.dataOj!.value.isEmpty == false) {
            if (self.indexed) {
                for (key, value) in self.groupedData {
                    if (value.contains(self.dataOj!.value)) {
                        let section = self.indexKeys.firstIndex(of: key) ?? 0
                        let row = value.firstIndex(of: self.dataOj!.value) ?? 0
                        let indexPath = NSIndexPath(row: row, section: section) as IndexPath
                        self.tableView?.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
            } else {
                let index = self.dataOj?.textSuggestions?.firstIndex(of: self.dataOj!.value)
                if (index != nil && index! >= 0 && index! < self.dataOj!.textSuggestions!.count) {
                    let indexPath = NSIndexPath(row: index!, section: 0) as IndexPath
                    self.tableView?.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = self.indexed ? self.groupedData[self.indexKeys[indexPath.section]]![indexPath.row] : self.dataOj!.textSuggestions![indexPath.row]
        if (self.isMultiple) {
            if (self.selectedItems.contains(str)) {
                self.selectedItems.remove(at: self.selectedItems.firstIndex(of: str)!)
            } else {
                self.selectedItems.append(str)
            }
            self.valueLabel.text = self.selectedItems.joined(separator: ", ")
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let _ = self.triggerValueChange(value: self.valueLabel.text!, titleLabel: self.titleLabel)
            }
        } else {
            if (self.allowDeselect) {
                self.valueLabel.text = self.valueLabel.text == str ? "" : str
            } else {
                self.valueLabel.text = str
            }
            tableView.reloadData()

            let _ = self.focus()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let _ = self.triggerValueChange(value: self.valueLabel.text!, titleLabel: self.titleLabel)
                let _ = self.cellCallbackDelegate?.cellCallback(CellRequest.updateHeight)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.indexed ? self.indexKeys.count : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.indexed ? self.groupedData[self.indexKeys[section]]!.count : self.dataOj!.textSuggestions!.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.indexed ? self.indexKeys[section] : ""
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.indexed ? self.indexKeys : nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.indexed ? 32 : 0.01
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "FormExpandTableCellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellId)
        }
        let text = self.indexed ? self.groupedData[self.indexKeys[indexPath.section]]![indexPath.row] : self.dataOj!.textSuggestions![indexPath.row]
        cell?.textLabel?.text = text
        if cell?.textLabel?.text == self.valueLabel.text || self.selectedItems.contains(text) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        return cell!
    }
}
