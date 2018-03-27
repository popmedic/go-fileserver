//
//  DefaultModel.swift
//  FileView
//
//  Created by Kevin Scardina on 3/22/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

class DefaultModel: ModelProtocol {
    func create(_ key: String, value: Any) {
        set(key, value:value)
    }
    func get(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    func set(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    func delete(_ key: String) -> Any? {
        let obj = get(key)
        UserDefaults.standard.removeObject(forKey: key)
        return obj
    }
}
