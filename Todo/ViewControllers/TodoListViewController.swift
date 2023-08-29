//
//  ViewController.swift
//  Todo
//
//  Created by Anshul parashar on 18/08/23.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

	@IBOutlet weak var searchBar: UISearchBar!

	private var itemResults: Results<TodoItem>?

	private let realm: Realm? = {
		do {
			return try Realm()
		} catch {
			print("Error while creating Realm instance: \(error)")
		}
		return nil
	}()

	var selectedCategory: Category? {
		didSet {
			loadItems()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		loadItems()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureNavigationBarAppearance()
	}

	@IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
		let alertViewController = UIAlertController(title: "Add a new todo", message: nil, preferredStyle: .alert)
		alertViewController.addTextField { textField in
			textField.placeholder = "Create a todo item"
		}
		alertViewController.addAction(UIAlertAction(title: "Add item", style: .default, handler: { [weak self] action in
			guard let textFieldText = alertViewController.textFields?.first?.text,
				  !textFieldText.isEmpty,
				  let strongSelf = self,
				  let selectedCategory = strongSelf.selectedCategory else {
				return
			}

			do {
				try strongSelf.realm?.write({
					let item = TodoItem()
					item.title = textFieldText
					item.dateCreated = Date.now
					selectedCategory.items.append(item)
				})
			} catch {
				print("Error while adding todo item: \(error.localizedDescription)")
			}

			strongSelf.tableView.reloadData()
		}))

		alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alertViewController, animated: true, completion: nil)
	}

	private func loadItems() {
		itemResults = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
		tableView.reloadData()
	}

	override func updateModel(at indexPath: IndexPath) {
		do {
			try realm?.write({ [weak self] in
				self?.selectedCategory?.items.remove(at: indexPath.row)
			})
		} catch {
			print("Error while deleting Category: \(error)")
		}
	}

	// MARK: Private

	private func configureNavigationBarAppearance() {
		guard let selectedCategory = selectedCategory, let categoryColor = UIColor(hexString: selectedCategory.hexColor) else {
			return
		}

		title = selectedCategory.name
		let contrastColor = ContrastColorOf(categoryColor, returnFlat: true)

		let standardAppearance = navigationController?.navigationBar.standardAppearance
		standardAppearance?.backgroundColor = categoryColor
		standardAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastColor]
		standardAppearance?.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor : contrastColor,
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)
		]

		let scrollEdgeAppearance = navigationController?.navigationBar.scrollEdgeAppearance
		scrollEdgeAppearance?.backgroundColor = categoryColor
		scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastColor]
		scrollEdgeAppearance?.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor : contrastColor,
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)
		]

		navigationController?.navigationBar.tintColor = contrastColor
		searchBar.barTintColor = categoryColor
		searchBar.searchTextField.backgroundColor = .systemBackground
	}
}

// MARK: UITableViewDataSource

extension TodoListViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemResults?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		if let itemResults = itemResults,
		   let selectedCategory = selectedCategory,
		   let selectedCategoryColor = UIColor(hexString: selectedCategory.hexColor),
		   let backgroundColor = selectedCategoryColor.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemResults.count)) {
			let item = itemResults[indexPath.row]
			var contentConfig = cell.defaultContentConfiguration()
			contentConfig.text = item.title
			contentConfig.textProperties.color = UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true)
			cell.accessoryType = item.done ? .checkmark : .none
			cell.contentConfiguration = contentConfig
			cell.backgroundColor = backgroundColor
		}
		return cell
	}
}

// MARK: UITableViewDelegate

extension TodoListViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath),
			  let itemResults = itemResults, itemResults.count > 0 else {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}

		let item = itemResults[indexPath.row]
		do {
			try realm?.write({
				item.done = !item.done
			})
		} catch {
			print("Error while updating todo item: \(error)")
		}

		cell.accessoryType = item.done ? .checkmark : .none
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let text = searchBar.text, !text.isEmpty else {
			return
		}

		itemResults = itemResults?.filter("title CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: false)
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard let text = searchBar.text, text.isEmpty else {
			return
		}
		loadItems()
		DispatchQueue.main.async {
			searchBar.resignFirstResponder()
		}
	}
}
