//
//  ViewController.swift
//  Alarminator
//
//  Created by Yury on 10/18/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import UIKit

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
}

