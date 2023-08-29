//
//  SwipeTableViewController.swift
//  Todo
//
//  Created by Anshul parashar on 24/08/23.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

	private static let cellID = "SwipeCell"
	private static let cellHeight: CGFloat = 80

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.rowHeight = SwipeTableViewController.cellHeight
    }

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: SwipeTableViewController.cellID, for: indexPath) as? SwipeTableViewCell else {
			return UITableViewCell()
		}
		cell.delegate = self
		return cell
	}

	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard orientation == .right else {
			return nil
		}

		let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
			self?.updateModel(at: indexPath)
		}

		deleteAction.image = UIImage(named: "delete-icon")
		return [deleteAction]
	}

	func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .destructive
		return options
	}

	func updateModel(at indexPath: IndexPath) {
		// No operation
	}
}
