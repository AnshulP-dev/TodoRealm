//
//  TodoItem.swift
//  Todo
//
//  Created by Anshul parashar on 23/08/23.
//

import Foundation
import RealmSwift

class TodoItem: Object {
	@objc dynamic var title: String = ""
	@objc dynamic var done: Bool = false
	@objc dynamic var dateCreated: Date = Date.now
	var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
