//
//  CategoryViewController.swift
//  Todo
//
//  Created by Anshul parashar on 23/08/23.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

	private static let categoryToItemsSegueID = "CategoryToItems"
	private static let defaultCellBackgroundHexColor = "32ADE6"

	private let realm: Realm? = {
		do {
			return try Realm()
		} catch {
			print("Error while creating Realm instance: \(error)")
		}
		return nil
	}()

	private var categories: Results<Category>?

	// MARK: Override

	override func viewDidLoad() {
		super.viewDidLoad()
		loadCategories()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureNavigationBarAppearance()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let todoListViewController = segue.destination as? TodoListViewController,
			  let selectedIndexPath = tableView.indexPathForSelectedRow else {
			return
		}

		todoListViewController.selectedCategory = categories?[selectedIndexPath.row]
	}

	override func updateModel(at indexPath: IndexPath) {
		guard let category = categories?[indexPath.row] else {
			return
		}

		do {
			try realm?.write({
				realm?.delete(category)
			})
		} catch {
			print("Error while deleting Category: \(error)")
		}
	}

	// MARK: Action Handler

	@IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
		let alertViewController = UIAlertController(title: "Add a new category like Shopping, Travel, Work etc", message: nil, preferredStyle: .alert)
		alertViewController.addTextField { textField in
			textField.placeholder = "Create a category"
		}
		alertViewController.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] action in
			guard let textFieldText = alertViewController.textFields?.first?.text,
				  !textFieldText.isEmpty,
				  let strongSelf = self else {
				return
			}

			let category = Category()
			category.name = textFieldText
			category.hexColor = UIColor.randomFlat().hexValue()
			strongSelf.save(category: category)
			strongSelf.tableView.reloadData()
		}))

		alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alertViewController, animated: true, completion: nil)
	}

	// MARK: Data manipulation

	private func loadCategories() {
		categories = realm?.objects(Category.self)
		tableView.reloadData()
	}

	private func save(category: Category) {
		do {
			try realm?.write({
				realm?.add(category)
			})
		} catch {
			print("Error while saving Categories: \(error.localizedDescription)")
		}
	}

	// MARK: Private

	private func configureNavigationBarAppearance() {
		navigationController?.navigationBar.prefersLargeTitles = true
		let standardAppearance = navigationController?.navigationBar.standardAppearance
		standardAppearance?.backgroundColor = UIColor(hexString: CategoryViewController.defaultCellBackgroundHexColor)
		standardAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		standardAppearance?.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor : UIColor.white,
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)
		]

		let scrollEdgeAppearance = navigationController?.navigationBar.scrollEdgeAppearance
		scrollEdgeAppearance?.backgroundColor = UIColor(hexString: CategoryViewController.defaultCellBackgroundHexColor)
		scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		scrollEdgeAppearance?.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor : UIColor.white,
			NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)
		]
		navigationController?.navigationBar.tintColor = .systemBackground
	}
}

// MARK: UITableViewDataSource

extension CategoryViewController {

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		let category = categories?[indexPath.row]
		var contentConfig = cell.defaultContentConfiguration()
		contentConfig.text = category?.name
		if let cellBackgroundColor = UIColor(hexString: category?.hexColor ?? CategoryViewController.defaultCellBackgroundHexColor) {
			cell.backgroundColor = cellBackgroundColor
			contentConfig.textProperties.color = UIColor(contrastingBlackOrWhiteColorOn: cellBackgroundColor, isFlat: true)
		}
		cell.contentConfiguration = contentConfig
		return cell
	}
}

// MARK: UITableViewDelegate

extension CategoryViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: CategoryViewController.categoryToItemsSegueID, sender: self)
	}
}
