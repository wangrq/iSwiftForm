//
//  AutoCompleteTextField.swift
//
//  Edited by Renquan Wang on 2017-08-21.
//  Original Code is from Stack Overflow
//

import UIKit

class AutoCompleteTextField: UITextField {
    var tempHideSuggestions: Bool = false
    fileprivate var autoCompleteTableView:UITableView?
    fileprivate lazy var attributedAutoCompleteStrings: [NSAttributedString] = [NSAttributedString]()
    open var onSelect:(String, IndexPath)->() = {_,_ in}
    open var onTextChange:(String)->() = {_ in}

    open var autoCompleteTextFont: UIFont = UIFont.systemFont(ofSize: 12)
    open var autoCompleteTextColor: UIColor = UIColor.black
    open var autoCompleteCellHeight:CGFloat = 44.0
    open var maximumAutoCompleteCount: Int = 20
    open var autoCompleteSeparatorInset = UIEdgeInsets.zero
    open var enableAttributedText: Bool = false
    open var hidesWhenSelected: Bool = true
    open var hidesWhenEmpty:Bool?{
        didSet{
            assert(hidesWhenEmpty != nil, "hideWhenEmpty cannot be set to nil")
            autoCompleteTableView?.isHidden = hidesWhenEmpty!
        }
    }
    open var autoCompleteTableHeight:CGFloat?{
        didSet{
            redrawTable()
        }
    }

    open var autoCompleteStrings:[String]?{
        didSet{ reload() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        //setupAutocompleteTable(superview!)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
        //setupAutocompleteTable(superview!)
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //commonInit()
        //setupAutocompleteTable(newSuperview!, self.autoCompleteTableView!)
    }

    fileprivate func commonInit(){
        hidesWhenEmpty = true
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(AutoCompleteTextField.textFieldDidEndEditing), for: .editingDidEnd)
    }

    func autoSetup(view: UIView, textChoiceSource: TextSuggestionSource) {
        self.onTextChange = { text in
            self.autoCompleteStrings = textChoiceSource.getText(text)
        }
    }

    func autoSetup(view: UIView, choices: [String]) {
        let strdb = choices.map({ $0.lowercased() })
        self.onTextChange = { text in
            let textlower = text.lowercased()
            var strs: [String] = [String]()
            for (index, value) in strdb.enumerated() {
                if (value.contains(textlower)) {
                    strs.append(choices[index])
                }
            }
            self.autoCompleteStrings = strs
        }
    }

    open func setupAutocompleteTable(_ view: UIView, _ tableView: UITableView){
        let inputFieldPoint = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y)
        let p = self.superview!.convert(inputFieldPoint, to: view)
        tableView.frame = CGRect(x: p.x, y: p.y + self.frame.height - tableView.contentInset.bottom, width: self.frame.width, height: 300.0)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = autoCompleteCellHeight
        tableView.isHidden = hidesWhenEmpty ?? true
        autoCompleteTableView = tableView
    }

    fileprivate func redrawTable(){
        if let autoCompleteTableView = autoCompleteTableView, let autoCompleteTableHeight = autoCompleteTableHeight {
            var newFrame = autoCompleteTableView.frame
            newFrame.size.height = autoCompleteTableHeight
            autoCompleteTableView.frame = newFrame
        }
    }

    fileprivate func reload(){
        autoCompleteTableView?.reloadData()
    }

    @objc func textFieldDidChange(){
        guard let _ = text else {
            return
        }

        onTextChange(text!)
        if (self.tempHideSuggestions) {
            self.autoCompleteTableView?.isHidden = true
            return;
        }
        if text!.isEmpty{ autoCompleteStrings = nil }
        //DispatchQueue.main.async(execute: { () -> Void in
        self.autoCompleteTableView?.isHidden =  self.hidesWhenEmpty! ? (self.text!.isEmpty || autoCompleteStrings?.count == 0 ) : false
        //})
    }

    @objc func textFieldDidEndEditing() {
        autoCompleteTableView?.isHidden = true
    }
}

extension AutoCompleteTextField: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteStrings != nil ? (autoCompleteStrings!.count > maximumAutoCompleteCount ? maximumAutoCompleteCount : autoCompleteStrings!.count) : 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "autocompleteCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        }

        if enableAttributedText{
            cell?.textLabel?.attributedText = attributedAutoCompleteStrings[indexPath.row]
        }
        else{
            cell?.textLabel?.font = autoCompleteTextFont
            cell?.textLabel?.textColor = autoCompleteTextColor
            cell?.textLabel?.text = autoCompleteStrings![indexPath.row]
        }

        cell?.contentView.gestureRecognizers = nil
        return cell!
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        if let selectedText = cell?.textLabel?.text {
            self.text = selectedText
            onSelect(selectedText, indexPath)
        }

        DispatchQueue.main.async(execute: { () -> Void in
            tableView.isHidden = self.hidesWhenSelected
        })
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = autoCompleteSeparatorInset
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)){
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = autoCompleteSeparatorInset
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return autoCompleteCellHeight
    }
}
