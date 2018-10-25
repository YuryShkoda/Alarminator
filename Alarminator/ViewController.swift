//
//  ViewController.swift
//  Alarminator
//
//  Created by Yury on 10/18/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UITableViewController {
    var groups = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Alarminator"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: Notification.Name("save"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        groups.remove(at: indexPath.row)
        
        save()
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = groups[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)
        cell.textLabel?.text = group.name
        
        if group.enabled {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        
        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        } else {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupToEdit: Group
        
        if sender is Group {
            // this method was called from addGroup()
            groupToEdit = sender as! Group
        } else {
            // this method was called by a table view cell
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            
            groupToEdit = groups[selectedIndexPath.row]
        }
        
        // unwrap segue destination
        if let groupViewController = segue.destination as? GroupViewController {
            groupViewController.group = groupToEdit
        }
    }
    
    @objc func addGroup() {
        let newGroup = Group(name: "Name this group", playSound: true, enabled: false, alarms: [])
        groups.append(newGroup)
        
        save()
        
        performSegue(withIdentifier: "EditGroup", sender: newGroup)
    }
    
    @objc func save() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = NSKeyedArchiver.archivedData(withRootObject: groups)
            
            try data.write(to: path)
        } catch {
            print("Failed to save")
        }
        
        updateNotifications()
    }
    
    func load() {
        do {
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = try Data(contentsOf: path)
            
            groups = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Group] ?? [Group]()
        } catch {
            print("Failed to load")
        }
        
        tableView.reloadData()
    }
    
    func updateNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { [unowned self] (granted, error) in
            if granted {
                self.createNotifications()
            }
        }
    }
    
    func createNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        for group in groups {
            guard group.enabled == true else { continue }
            
            for alarm in group.alarms {
                let notification = createNotificationRequest(group: group, alarm: alarm)
                
                center.add(notification) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
    
    func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = alarm.name
        content.body  = alarm.caption
        content.categoryIdentifier = "alarm"
        
        if group.playSound { content.sound = UNNotificationSound.default }
        
        content.attachments = createNotificationAttachments(alarm: alarm)
        
        let cal = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.hour   = cal.component(.hour, from: alarm.time)
        dateComponents.minute = cal.component(.minute, from: alarm.time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        return request
    }
    
    func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        guard alarm.image.count > 0 else { return [] }
        
        let fm = FileManager.default
        
        do {
            let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            let copyURL  = Helper.getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
            
            try fm.copyItem(at: imageURL, to: copyURL)
            
            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL)
            
            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            
            return []
        }
    }
}

