//
//  ViewController.swift
//  TestProject
//
//  Created by Renquan Wang on 2019-05-13.
//  Copyright © 2019 MSO.APP. All rights reserved.
//

import UIKit
import iSwiftForm

class DataHolder: FormBaseDataHolder {
    override func fillFormData() {
        var group = FormDataGroup("Basic Info")
        group += FormData(CellType.Input).config(title: "Name", value: "John", textSuggestions: ["John Snow", "John Green"])
        group += FormData(CellType.SegmentedControl).config(title: "Gender", value: "Male", textSuggestions: ["Male", "Female"])
        group += FormData(CellType.DateTime).config(title: "Birth", value: "1990-06-06")
        group += FormData(CellType.Input).config(title: "Email").validator(.email).inputType(.email)
        self.append(group)

        group = FormDataGroup("More Info")
        group += FormData(CellType.ExpandTable).config(title: "Mood", value: "😝", textSuggestions: ["😝", "😭", "☹️"])
        group += FormData(CellType.ExpandTable).config(title: "Favorite Foods", value: "", textSuggestions: ["🍔", "🍜", "🌽"]).options(["type": "multiple"])
        self.append(group)

        group = FormDataGroup("ID Number")
        group += FormData(CellType.Input).config(title: "Phone Number").valuePlaceHolder("Your Phone Number").inputType(.phone)
        group += FormData(CellType.Button).config(title: "Scan a QR code")
        self.append(group)

        group = FormDataGroup()
        group += FormData(CellType.Text).config(title: "I have read the Agreement and agree to the terms and conditions.")
        group += FormData(CellType.Signature).config(title: "Signature")
        self.append(group)

        group = FormDataGroup()
        group += FormData(CellType.Input).config(title: "Printed Name")
        group += FormData(CellType.ButtonBig).config(title: "Submit").options(["color": "none"])
        self.append(group)
    }

    override func valueChanged(sectionNumber: Int, rowNumber: Int, value: String, formData: FormData) -> Bool {
        return true;
    }
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("OK!");
    }
    override func viewDidAppear(_ animated: Bool) {
        let vc = DataHolder().attach(FormBaseController());
        self.present(vc, animated: true, completion: nil);
    }
}

