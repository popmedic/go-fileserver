//
//  Model.swift
//  FileView
//
//  Created by Kevin Scardina on 3/22/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

import UIKit

protocol ModelProtocol {
    associatedtype Item
    associatedtype ID
    mutating func create(_ key: ID, value: Item) throws
    mutating func get(_ key: ID) throws -> Item?
    mutating func set(_ key: ID, value: Item) throws
    mutating func delete(_ key: ID) throws -> Item?
}
