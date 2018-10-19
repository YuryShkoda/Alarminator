//
//  Group.swift
//  Alarminator
//
//  Created by Yury on 10/19/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import UIKit

class Group: NSObject {
    var id:        String
    var name:      String
    var playSound: Bool
    var enabled:   Bool
    var alarms:    [Alarm]
    
    init(name: String, playSound: Bool, enabled: Bool, alarms: [Alarm]) {
        self.id        = UUID().uuidString
        self.name      = name
        self.playSound = playSound
        self.enabled   = enabled
        self.alarms    = alarms
    }
}
