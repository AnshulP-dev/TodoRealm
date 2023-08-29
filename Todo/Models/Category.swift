//
//  Category.swift
//  Todo
//
//  Created by Anshul parashar on 23/08/23.
//

import Foundation
import RealmSwift

class Category: Object {
	@objc dynamic var name: String = ""
	@objc dynamic var hexColor: String = ""
	var items = List<TodoItem>()
}
