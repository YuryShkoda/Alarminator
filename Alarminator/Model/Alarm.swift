//
//  Alarm.swift
//  Alarminator
//
//  Created by Yury on 10/19/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import UIKit

class Alarm: NSObject {
    var id:      String
    var name:    String
    var caption: String
    var image:   String
    var time:    Date
    
    init(name: String, caption: String, time: Date, image: String) {
        self.id      = UUID().uuidString
        self.name    = name
        self.caption = caption
        self.time    = time
        self.image   = image
    }
}
