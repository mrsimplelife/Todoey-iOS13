//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    //    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    //    let defaults = UserDefaults.standard
    //    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        //        let newItem = Item(title: "Find Milk")
        //        itemArray.append(newItem)
        //        let newItem2 = Item(title: "Buy Eggos", done: true)
        //        itemArray.append(newItem2)
        //        let newItem3 = Item(title: "Destory Demogorgon", done: true)
        //        itemArray.append(newItem3)

        //        searchBar.searchTextField.delegate = self
        //        if let itemArray = defaults.array(forKey: "TodoListArray") as? [Item] {
        //            self.itemArray =

        //        loadItems()
    }
    //MARK: - UITableViewDataSource

    // Return the number of rows for the table.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    // Provide a cell object for each row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        // Configure the cell’s contents.
        cell.textLabel!.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        //        context.delete(itemArray[indexPath.row])
        saveItems()

        DispatchQueue.main.async {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = self.itemArray[indexPath.row].done ? .checkmark : .none
            self.tableView.deselectRow(at: indexPath, animated: true)
            //        itemArray.remove(at: indexPath.row)
            //        tableView.reloadData()
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
            //            let item = Item(title: textField.text!)
            let item = Item(context: self.context)
            item.title = textField.text
            item.done = false
            item.parentCategory = self.selectedCategory
            self.saveItems()

            self.itemArray.append(item)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        alert.addAction(action)
        DispatchQueue.main.async { self.present(alert, animated: true) }
    }
    //MARK: - saveItems
    func saveItems() {
        //            self.defaults.set(self.itemArray, forKey: "TodoListArray")
        //        let encoder = PropertyListEncoder()
        do {
            //            let data = try encoder.encode(itemArray)
            //            try data.write(to: dataFilePath!)
            try context.save()
        } catch {
            //            print("Error encoding item array, \(error)")
            print("Error saving context, \(error)")
        }
    }
    //MARK: - loadItems
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //        NSFetchRequest<Item>
        var subpredicates = [NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)]
        if predicate != nil {
            subpredicates.append(predicate!)
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        do {
            itemArray = try context.fetch(request)
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        catch {
            print("Error fetching context, \(error)")
        }

        //            if let data = try? Data(contentsOf: dataFilePath!) {
        //                let decoder = PropertyListDecoder()
        //                do {
        //                    itemArray = try decoder.decode([Item].self, from: data)
        //                } catch {
        //                    print("Error decoding item array, \(error)")
        //                }
        //
        //            }
    }

}

//MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
        }
    }

}

//extension TodoListViewController: UISearchTextFieldDelegate {
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        loadItems()
//        DispatchQueue.main.async {
//            self.searchBar.resignFirstResponder()
//        }
//        return true
//    }
//}
