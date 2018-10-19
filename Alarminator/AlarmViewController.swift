//
//  AlarmViewController.swift
//  Alarminator
//
//  Created by Yury on 10/19/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import UIKit

class AlarmViewController: UITableViewController {
    var alarm: Alarm!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tapToSelectImage: UILabel!
    
    @IBAction func datePickerChanged(_ sender: Any) {
    }
    
    @IBAction func imageViewTapped(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
