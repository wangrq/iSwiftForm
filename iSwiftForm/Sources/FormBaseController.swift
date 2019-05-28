//
//  FormBaseViewController.swift
//
//  Created by Renquan Wang on 2017-08-23.
//  Copyright © 2017 Renquan Wang. All rights reserved.
//

import UIKit

public enum CellType: String {
    case Input = "FormInputCell"
    case SegmentedControl = "FormSegmentedControl"
    case ExpandTable = "FormExpandTableCell"
    case DateTime = "FormDateTimeCell"
    case Signature = "FormSignatureCell"
    case Text = "FormTextCell"
    case Button = "FormButtonCell"
    case ButtonBig = "FormButtonBigCell"
    fileprivate static let allTypes = [CellType.Input, CellType.SegmentedControl, CellType.ExpandTable, CellType.DateTime, CellType.Signature, CellType.Text, CellType.Button, CellType.ButtonBig]
    fileprivate static var customTypes: [String] = []
    static func register(_ newType: String) {
        if (CellType.customTypes.contains(newType) == false) {
            CellType.customTypes.append(newType)
        }
    }
}

open class TextSuggestionSource {
    func getText(_ key: String) -> [String] {
        return []
    }
}

open class FormDataGroup {
    var name: String
    var data: [FormData]
    public init() {
        self.name = ""
        self.data = []
    }
    public init(_ name: String) {
        self.name = name
        self.data = []
    }
    public func append(_ formData: FormData) {
        self.data.append(formData)
    }
    static public func +=(left: inout FormDataGroup, right: FormData) {
        left.append(right)
    }
}

/**
 * Form Validation Base Class
 */
open class Validator {
    func test(value: String?) -> Bool {
        return false
    }
}

/**
 * Non-empty validator. (nil or "") won't pass it.
 */
class NoEmptyValidator: Validator {
    override func test(value: String?) -> Bool {
        return value != nil && value != ""
    }
}

/**
 * Email validator.
 */
class EmailValidator: Validator {
    let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    override func test(value: String?) -> Bool {
        return value != nil && value != "" && emailTest.evaluate(with: value!)
    }
}

/**
 * Min characters count validator. Value characters count should be bigger or equal to [min]
 */
class MinValidator: Validator {
    var min: Int = 0
    init(min: Int) {
        self.min = min
    }
    override func test(value: String?) -> Bool {
        return value != nil && value!.count >= min
    }
}

/**
 * Fixed characters count validator. Value characters count should be exactly match one of the integer in the [count] array
 */
class FixedValidator: Validator {
    var count: [Int] = [1]
    init(count: [Int]) {
        self.count = count
    }
    override func test(value: String?) -> Bool {
        return value != nil && self.count.contains(value!.count)
    }
}

/**
 * Integer validator. Value shouls be able to be converetd to an integer
 */
class IntegerValidator: Validator {
    override func test(value: String?) -> Bool {
        if (value == nil) {
            return false
        }
        return Int(value!) != nil
    }
}

public enum Validators: Int {
    case none
    case noEmpty
    case minChar
    case integer
    case fixedCount
    case email
}

public enum InputType: Int {
    case none
    case text
    case capWord
    case email
    case number
    case phone
}

open class FormData: Hashable, Equatable {
    var id = 0
    let type: String
    var title: String = ""
    var value: String = ""
    open var key: String = ""
    var cellHeight: CGFloat = 44
    var enable: Bool = true
    var tag: Any? = nil

    var inputType: InputType = InputType.text
    var valuePlaceHolder: String? = nil
    var textSuggestionSource: TextSuggestionSource? = nil
    var contentOptions: [String: Any]? = nil
    var textSuggestions: [String]? = nil

    var valueChangeCallback: FormValueChangeDelegate?
    var options: [String: String]?
    var validator: Validator?

    var nextSection: Int = -1
    var nextRow: Int = -1

    static public func ==(lhs: FormData, rhs: FormData) -> Bool {
        return lhs.id == rhs.id
    }
    open var hashValue: Int {
        get {
            return self.id
        }
    }

    static var idIndex: Int = 0
    static func getId() -> Int {
        if (FormData.idIndex == Int.max - 1) {
            FormData.idIndex = 0
        }
        FormData.idIndex = FormData.idIndex + 1
        return idIndex
    }

    public init(_ type: String) {
        self.type = type
        self.id = FormData.getId()
        self.commonInit()
    }

    public init(_ type: CellType) {
        self.type = type.rawValue
        self.id = FormData.getId()
        self.commonInit()
    }

    open func config(title: String) -> FormData {
        self.title = title
        return self
    }

    open func config(title: String, value: String? = nil) -> FormData {
        self.title = title
        if let v = value {
            self.value = v
        }
        return self
    }

    open func config(title: String, textSuggestionSource: TextSuggestionSource, value: String? = nil) -> FormData {
        self.title = title
        if let v = value {
            self.value = v
        }
        self.textSuggestionSource = textSuggestionSource
        return self
    }

    open func config(title: String, textSuggestions: [String], value: String? = nil) -> FormData {
        self.title = title
        if let v = value {
            self.value = v
        }
        self.textSuggestions = textSuggestions
        return self
    }

    open func itemKey(_ key: String, _ holder: FormBaseDataHolder? = nil) -> FormData {
        self.key = key
        if (self.value.count == 0 && self.key.count > 0) {
            self.value = holder?.formData[self.key] ?? ""
        }
        return self
    }

    func commonInit() {
        switch self.type {
        case CellType.Text.rawValue,
             CellType.Button.rawValue,
             CellType.ButtonBig.rawValue:
            break;
        default:
            let _ = self.validator(.noEmpty)
        }
    }

    func delegate(_ callback: FormValueChangeDelegate) -> FormData {
        self.valueChangeCallback = callback
        return self
    }

    open func options(_ options: [String: String]) -> FormData {
        self.options = options
        return self
    }

    open func enable(_ enable: Bool) -> FormData {
        self.enable = enable
        if (enable == false) {
            return self.validator(.none, nil)
        }
        return self
    }

    open func valuePlaceHolder(_ valuePlaceHolder: String) -> FormData {
        self.valuePlaceHolder = valuePlaceHolder
        return self
    }

    open func contentOptions(_ contentOptions: [String: Any]) -> FormData {
        self.contentOptions = contentOptions
        return self
    }

    open func inputType(_ type: InputType) -> FormData {
        self.inputType = type
        return self
    }

    func inputTypeToName() -> FormData {
        self.inputType = InputType.capWord
        return self
    }

    open func validator(_ validator: Validator) -> FormData {
        self.validator = validator
        return self
    }

    open func validator(_ type: Validators, _ options: [String: Any]? = nil) -> FormData {
        switch type {
        case Validators.none:
            self.validator = nil
        case Validators.minChar:
            if let ops = options, let min = ops["min"] as? Int {
                self.validator = MinValidator(min: min)
            } else {
                self.validator = MinValidator(min: 4)
            }
        case Validators.fixedCount:
            if let ops = options, let count = ops["count"] as? [Int] {
                self.validator = FixedValidator(count: count)
            } else {
                self.validator = FixedValidator(count: [4])
            }
        case Validators.integer:
            self.validator = IntegerValidator()
        case Validators.email:
            self.validator = EmailValidator()
        default:
            self.validator = NoEmptyValidator()
        }
        return self
    }

    open func validate() -> Bool {
        if (self.validator == nil) {
            return true
        } else {
            return self.validator?.test(value: self.value) ?? false
        }
    }
}

open class CommonDataHolder {
    public init() {}

    open func validate() -> Bool {
        return true
    }

    open func attach(_ page: FormBaseController) -> FormBaseController {
        return FormBaseController()
    }

    fileprivate func reloadFormData() {
        //
    }

    open func fillFormData() {
        //
    }

    open func shouldUpdateWhenAppear() -> Bool {
        return false
    }
}

open class FormBaseDataHolder: CommonDataHolder {
    open var data: [FormDataGroup] = [FormDataGroup]()
    var formData: [String: String] = [:]

    var pageIndex: IndexPath?

    weak open var page: FormBaseController?

    func formData(_ formData: [String: String]) -> FormBaseDataHolder {
        self.formData = formData
        return self
    }
    override func reloadFormData() {
        self.data = []
        self.fillFormData()
    }

    open func append(_ formDataGroup: FormDataGroup) {
        self.data.append(formDataGroup)
    }

    open func valueChanged(sectionNumber: Int, rowNumber: Int, value: String, formData: FormData) -> Bool {
        return false
    }

    override open func validate() -> Bool {
        for section in self.data {
            for data in section.data {
                if (data.validate() == false) {
                    return false
                }
            }
        }
        return true
    }

    override open func attach(_ page: FormBaseController) -> FormBaseController {
        self.page = page
        page.dataHolder = self
        return page
    }

    open func requestUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if (self.page != nil) {
                self.page?.updateFormData()
                self.page?.tableView.reloadData()
            }
        })
    }
}

class FormDataHolderCollection: CommonDataHolder {
    var data: [FormBaseDataHolder?]
    init(data: [FormBaseDataHolder?]) {
        self.data = data
    }
    override func validate() -> Bool {
        for holder in self.data {
            if (holder != nil) && holder?.validate() == false {
                return false
            }
        }
        return true
    }

    override func reloadFormData() {
        for dataHolder in data {
            if let holder = dataHolder {
                holder.reloadFormData()
            }
        }
    }
}

open class FormBaseController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellCallback, FormValueChangeDelegate {
    var tableView: UITableView!
    var oldBottomInset: CGFloat?
    var extraRowKeyboardSpacing: CGFloat = 50
    var autoCompleteTableView: UITableView?
    var tempFocusCell: UITableViewCell?
    var isKeyboradShowing: Bool = false
    var lastScrollPosition: CGFloat = 0

    var dataHolder: FormBaseDataHolder = FormBaseDataHolder()
    lazy var inputToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()

        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)

        var nextButton  = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(FormBaseController.keyboardNextButton))
        nextButton.width = 80.0
        var previousButton = UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(FormBaseController.keyboardPreviousButton))
        previousButton.width = 80.0

        toolbar.setItems([flexibleSpaceButton, previousButton, fixedSpaceButton, nextButton], animated: false)
        toolbar.isUserInteractionEnabled = true

        return toolbar
    }()

    @objc func keyboardNextButton() {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let dataGroup = self.dataHolder.data[indexPath.section]
            let data = dataGroup.data[indexPath.row]

            tableView.deselectRow(at: indexPath, animated: false)
            if let cell = tableView.cellForRow(at: indexPath) as? FormBaseCell {
                let _ = cell.blur()
                if data.nextSection >= 0 {
                    let newIndexPath = NSIndexPath(row: data.nextRow, section: data.nextSection) as IndexPath

                    if let newCell = tableView.cellForRow(at: newIndexPath) as? FormBaseCell {
                        self.tableView.selectRow(at: newIndexPath, animated: true, scrollPosition: .top)

                        let req = newCell.focus()
                        if req == .updateHeight {
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                }
            }
        }
    }

    @objc func keyboardPreviousButton() {
        //print("keyboardPreviousButton")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = FormConfigs.tableViewSectionColor
        self.tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.tableView)

        // There is no way to create, in the iOS visual format language, a constraint pinning a view to its superview's safe area. So we'll use the deprecated topLayoutGuide/bottomLayoutGuide here.
        // https://stackoverflow.com/questions/46479288/swift-safe-area-layout-guide-and-visual-format-language?noredirect=1&lq=1
        let views: [String: Any] = ["tableView": self.tableView!, "topLayoutGuide": topLayoutGuide, "bottomLayoutGuide": bottomLayoutGuide]
        var horizontalOffset = FormConfigs.isIPad ? 24 : 0
        if self.navigationController?.modalPresentationStyle == .formSheet {
            horizontalOffset = 0
        }
        let hLayout = "H:|-\(horizontalOffset)-[tableView]-\(horizontalOffset)-|"
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hLayout, options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topLayoutGuide]-0-[tableView]-0-[bottomLayoutGuide]", options: [], metrics: nil, views: views))
        for cellType in CellType.allTypes {
            let nib = UINib(nibName: cellType.rawValue, bundle: FormConfigs.bundle)
            self.tableView.register(nib, forCellReuseIdentifier: cellType.rawValue)
        }
        for cellType in CellType.customTypes {
            let nib = UINib(nibName: cellType, bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: cellType)
        }
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 44
        self.tableView.separatorInset = UIEdgeInsets.zero
        //tableView.delaysContentTouches = false
        //tableView.tableFooterView = UIView()

        autoCompleteTableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300.0))
        autoCompleteTableView?.isHidden = true
        self.view.addSubview(autoCompleteTableView!)
        self.updateFormData()
    }

    func updateFormData() {
        self.dataHolder.reloadFormData()
        var previousData: FormData?
        for (snumber, section) in self.dataHolder.data.enumerated() {
            for (rowNumber, data) in section.data.enumerated() {
                let _ = data.delegate(self)
                if data.enable == true && data.type != CellType.Button.rawValue && data.type != CellType.ButtonBig.rawValue {
                    previousData?.nextSection = snumber
                    previousData?.nextRow = rowNumber
                    previousData = data
                }
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(FormBaseController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FormBaseController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if (self.dataHolder.shouldUpdateWhenAppear()) {
            self.updateFormData()
        }
        let selected = self.tableView.indexPathForSelectedRow
        self.tableView.reloadData()
        if selected != nil {
            self.tableView.selectRow(at: selected!, animated: false, scrollPosition: .none)
            if let cell = self.tableView.cellForRow(at: selected!) as? FormBaseCell {
                cell.reselectCell()
            }
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let formCell = cell as? FormBaseCell {
            var isOK = false;
            if let validator = formCell.dataOj?.validator {
                if (validator.test(value: formCell.dataOj?.value) && formCell is FormTextCell == false) {
                    isOK = true
                }
            }
            formCell.fillCellWithColor(isOK)
        }
    }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataObj = self.dataHolder.data[indexPath.section].data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: dataObj.type) as! FormBaseCell
        cell.setup(data: dataObj)
        cell.cellCallbackDelegate = self
        cell.containerTableView = self.tableView
        cell.selfIndexPath = indexPath

        if (dataObj.type == CellType.Input.rawValue) {
            let inputCell = cell as! FormInputCell
            //inputCell.inputField.inputAccessoryView = self.inputToolbar
            inputCell.inputField.inputAccessoryView = UIView()

            if let textSuggestionSource = dataObj.textSuggestionSource {
                inputCell.inputField.autoSetup(view: self.view, textChoiceSource: textSuggestionSource)
            } else if dataObj.enable {
                inputCell.inputField.autoSetup(view: self.view, choices: dataObj.textSuggestions ?? [])
            }
        }

        return cell
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataHolder.data.count
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataHolder.data[section].name
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataHolder.data[section].data.count
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataObj = self.dataHolder.data[indexPath.section].data[indexPath.row]
        return dataObj.cellHeight
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FormBaseCell {
            let result: CellRequest = cell.focus()
            if (result == CellRequest.deselect) {
                tableView.deselectRow(at: indexPath, animated: true)
            } else if (result == CellRequest.updateHeight) {
                DispatchQueue.main.async(execute: { () -> Void in
                    tableView.beginUpdates()
                    //tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                    //tableView.reloadData()
                })
            }
        }
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let rawCell = tableView.cellForRow(at: indexPath), let cell = rawCell as? FormBaseCell {
            let ret = cell.blur()
            if ret == .updateHeight {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.text = " \(self.dataHolder.data[section].name) "
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        //header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = FormConfigs.headerAlignment
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let floatView = self.autoCompleteTableView, self.isKeyboradShowing == true {
            let offset = scrollView.contentOffset.y - self.lastScrollPosition
            let oldY = floatView.frame.origin.y
            floatView.frame.origin.y = oldY - offset
            self.lastScrollPosition = scrollView.contentOffset.y
        }
    }

    func cellCallback(_ req: CellRequest?) -> String? {
        if (req == CellRequest.updateHeight) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return nil
    }

    func findIndexPath(ele: FormData) -> [String: Int] {
        var ret = ["section": -1, "index": 0]
        for index in 0..<self.dataHolder.data.count {
            let datai = self.dataHolder.data[index]
            if (datai.data.contains(ele)) {
                ret["section"] = index
                ret["index"] = datai.data.firstIndex(of: ele)!
            }
        }
        return ret
    }

    func onValueChange(_ ele: FormData, _ value: String) -> Bool {
        var indexPath: [String: Int] = self.findIndexPath(ele: ele)
        if indexPath["section"] == -1 {
            return false
        }
        let sectionNumber = indexPath["section"]!
        let rowNumber = indexPath["index"]!
        let ret = self.dataHolder.valueChanged(sectionNumber: sectionNumber, rowNumber: rowNumber, value: value, formData: ele)
        return ret
    }
}

extension UIView {
    public func findFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for subView in subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
    public func formCell() -> UITableViewCell? {
        if self is UITableViewCell {
            return self as? UITableViewCell
        }
        return superview?.formCell()
    }
}

extension FormBaseController {
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let table = tableView, let cell = table.findFirstResponder()?.formCell() else { return }
        self.tempFocusCell = cell
        let keyBoardInfo = notification.userInfo!
        let endFrame = keyBoardInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue

        let keyBoardFrame = table.window!.convert(endFrame.cgRectValue, to: table.superview)
        let newBottomInset = table.frame.origin.y + table.frame.size.height - keyBoardFrame.origin.y + extraRowKeyboardSpacing
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        oldBottomInset = oldBottomInset ?? tableInsets.bottom
        if newBottomInset > oldBottomInset! {
            tableInsets.bottom = newBottomInset
            scrollIndicatorInsets.bottom = tableInsets.bottom
            UIView.beginAnimations(nil, context: nil)
            let animationDuration = keyBoardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            UIView.setAnimationDuration(animationDuration)
            UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: (keyBoardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStop(#selector(scrollAnimationEnd))
            table.contentInset = tableInsets
            table.scrollIndicatorInsets = scrollIndicatorInsets
            if let selectedRow = table.indexPath(for: cell) {
                table.scrollToRow(at: selectedRow, at: .top, animated: false)
            }
            UIView.commitAnimations()
        } else {
            self.isKeyboradShowing = true
        }
    }

    @objc func scrollAnimationEnd() {
        if let cell = self.tempFocusCell, cell is FormInputCell {
            let inputCell = cell as! FormInputCell
            let inputField = inputCell.inputField
            inputField?.setupAutocompleteTable(self.view, self.autoCompleteTableView!)

            self.isKeyboradShowing = true
            self.lastScrollPosition = self.tableView.contentOffset.y
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.isKeyboradShowing = false
        guard let table = tableView, let oldBottom = oldBottomInset else { return }
        let keyBoardInfo = notification.userInfo!
        var tableInsets = table.contentInset
        var scrollIndicatorInsets = table.scrollIndicatorInsets
        tableInsets.bottom = oldBottom
        scrollIndicatorInsets.bottom = tableInsets.bottom
        oldBottomInset = nil
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration((keyBoardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double))
        UIView.setAnimationCurve(UIView.AnimationCurve(rawValue: (keyBoardInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int))!)
        table.contentInset = tableInsets
        table.scrollIndicatorInsets = scrollIndicatorInsets
        UIView.commitAnimations()
    }
}

class TableViewHelper {
    class func EmptyMessage(message: String, rootView: UIView, tableView: UITableView) {
        let frame = CGRect(x: 0, y: 0, width: rootView.bounds.size.width, height: rootView.bounds.size.height)
        let messageLabel = UILabel(frame: frame)
        messageLabel.text = message
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        tableView.backgroundView = messageLabel;
        tableView.separatorStyle = .none;
    }
    class func NoneEmptyMessage(tableView: UITableView) {
        tableView.backgroundView = UIView();
        tableView.separatorStyle = .singleLine;
    }
}
