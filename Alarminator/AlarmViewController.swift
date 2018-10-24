//
//  AlarmViewController.swift
//  Alarminator
//
//  Created by Yury on 10/19/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import UIKit

class AlarmViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var alarm: Alarm!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tapToSelectImage: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func datePickerChanged(_ sender: Any) {
        alarm.time = datePicker.date
        
        save()
    }
    
    @IBAction func imageViewTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        
        present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = alarm.name
        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time
        
        if alarm.image.count > 0 {
            let imageFileName = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            imageView.image = UIImage(contentsOfFile: imageFileName.path)
            
            tapToSelectImage.isHidden = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        let fm = FileManager()
        
        if alarm.image.count > 0 {
            do {
                let currentImage = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
                
                if fm.fileExists(atPath: currentImage.path) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
        }
        
        do {
            alarm.image = "\(UUID().uuidString).jpg"
            
            let newPath = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            let jpeg    = image.jpegData(compressionQuality: 80)
            
            try jpeg?.write(to: newPath)
            
            save()
        } catch {
            print("Failed to save new image")
        }
        
        imageView.image = image
        tapToSelectImage.isHidden = true
    }
    
    @objc func save() {
        NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        alarm.name    = name.text!
        alarm.caption = caption.text!
        title         = alarm.name
        
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
