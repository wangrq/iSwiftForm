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
    var rawData: [String: String] = [:]
    override func fillFormData() {
        var group = FormDataGroup("Basic Info")
        group += FormData(CellType.Input).config(title: "Name", textSuggestions: ["John Snow", "John Green"]).itemKey("name", self.rawData).validator(.none)
        group += FormData(CellType.Input).config(title: "Phone").itemKey("name", self.rawData).inputType(.phone)
        group += FormData(CellType.SegmentedControl).config(title: "Gender", textSuggestions: ["Male", "Female"]).itemKey("gender", self.rawData)
        group += FormData(CellType.DateTime).config(title: "Birth").itemKey("birth", self.rawData).options(["mode": "date"])
        group += FormData(CellType.Input).config(title: "Email").validator(.email).inputType(.email).itemKey("email", self.rawData)
        self.append(group)

        group = FormDataGroup("More Info")
        group += FormData(CellType.ExpandTable).config(title: "Mood", textSuggestions: ["😝", "😭", "☹️"]).itemKey("mood", self.rawData)
        group += FormData(CellType.ExpandTable).config(title: "Favorite Foods", textSuggestions: ["🍔", "🍜", "🌽"]).options(["type": "multiple"]).itemKey("food", self.rawData)
        self.append(group)

        group = FormDataGroup()
        group += FormData(CellType.ButtonBig).config(title: "Submit").options(["color": "none"]).itemKey("submit")
        self.append(group)
    }

    override func valueChanged(sectionNumber: Int, rowNumber: Int, value: String, formData: FormData) -> Bool {
        if (formData.key == "submit") {
            let isDone = self.validate()
            if (!isDone) {
                let alert = UIAlertController(title: "Failed", message: "Please complete all the required field", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.page?.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "OK", message: "Form is submitted", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.page?.present(alert, animated: true, completion: nil)
            }
        }else {
            self.rawData[formData.key] = value
        }
        return true;
    }
}


class DataHolder2: FormBaseDataHolder {
    var rawData: [String: String] = [:]
    override func fillFormData() {
        var group = FormDataGroup("ID Number")
        group += FormData(CellType.ExpandTable).config(title: "Nationality", textSuggestions: countries).itemKey("nationality", self.rawData)
        group += FormData(CellType.Input).config(title: "ID Number").valuePlaceHolder("Your ID Number").inputType(.phone).itemKey("idnumber", self.rawData)
        group += FormData(CellType.Button).config(title: "Scan a bar code")
        self.append(group)

        group = FormDataGroup()
        group += FormData(CellType.Text).config(title: "I have read the Agreement and agree to the terms and conditions.")
        group += FormData(CellType.Signature).config(title: "Signature").itemKey("signature", self.rawData)
        self.append(group)

        group = FormDataGroup()
        group += FormData(CellType.ButtonBig).config(title: "Submit").options(["color": "none"]).itemKey("submit")
        self.append(group)
    }

    override func valueChanged(sectionNumber: Int, rowNumber: Int, value: String, formData: FormData) -> Bool {
        if (formData.key == "submit") {
            let isDone = self.validate()
            if (!isDone) {
                let alert = UIAlertController(title: "Failed", message: "Please complete all the required field", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.page?.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "OK", message: "Form is submitted", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.page?.present(alert, animated: true, completion: nil)
            }
        }else {
            self.rawData[formData.key] = value
        }
        return true;
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        let vc = DataHolder().attach(FormBaseController());
        self.present(vc, animated: true, completion: nil);
    }
}

class CountrySelector: TextSuggestionSource {
    func getText(_ key: String) -> [String] {
        return []
    }
}

let countries = ["Afghanistan", "Åland Islands", "Albania", "Algeria", "American Samoa", "AndorrA", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, The Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote D\'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard Island and Mcdonald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic Of", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, Democratic People\'S Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan", "Lao People\'S Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "RWANDA", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia and Montenegro", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]
