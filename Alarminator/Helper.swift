//
//  Helper.swift
//  Alarminator
//
//  Created by Yury on 10/23/18.
//  Copyright © 2018 Yury Shkoda. All rights reserved.
//

import Foundation

struct Helper {
    static func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = path[0]
        
        return documentsDirectory
    }
}
