//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()

        }
    }

    @IBOutlet weak var searchBar: UISearchBar!

    //MARK: - loadItems
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        if let selectedCategory = selectedCategory {
            guard let navigationController = navigationController else { fatalError("Navigation controller does not exist.") }
            title = selectedCategory.name
            if let color = UIColor(hexString: selectedCategory.color) {
                navigationController.navigationBar.barTintColor = color
                navigationController.navigationBar.backgroundColor = color
                searchBar.barTintColor = color
                let contrastedColor = ContrastColorOf(color, returnFlat: true)
                navigationController.navigationBar.titleTextAttributes = [.foregroundColor: contrastedColor]
                navigationController.navigationBar.largeTitleTextAttributes = [.foregroundColor: contrastedColor]
                navigationController.navigationBar.tintColor = contrastedColor
            }

        }
    }
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel!.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel!.text = "No Items Added"
        }
        return cell
    }
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                    //                    realm.delete(item)
                }
            } catch {
                print("Error saving context, \(error)")
            }
            DispatchQueue.main.async {
                self.tableView.cellForRow(at: indexPath)?.accessoryType = item.done ? .checkmark : .none
            }
        }
        DispatchQueue.main.async {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    //MARK: - addButtonPressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        var textField = UITextField()
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let selectedCategory = self.selectedCategory {
                do {
                    try self.realm.write({
                        let item = Item()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        selectedCategory.items.append(item)
                    })
                } catch {
                    print("Error saving context, \(error)")
                }
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        alert.addAction(action)
        DispatchQueue.main.async { self.present(alert, animated: true) }
    }


    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write({
                    self.realm.delete(item)
                })
            } catch {
                print("Error saving context, \(error)")
            }
        }
    }
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        super.tableView(tableView, willBeginEditingRowAt: indexPath)
    }
}

//MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
        }
    }


}

