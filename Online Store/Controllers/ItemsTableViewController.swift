//
//  ItemsTableViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 31/12/2020.
//

import UIKit
import EmptyDataSet_Swift

class ItemsTableViewController: UITableViewController {

    
    // MARK: Vars
    var category: Category?
    var itemArray: [Item] = []
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("We have selected ",category!.name)
        tableView.tableFooterView = UIView()//remove the empty cells
        self.title = category?.name
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if category != nil {
            loadItems()
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(itemArray[indexPath.row])
        return cell
    }
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }
    
    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemToAddItemSeg"{
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    private func showItemView(_ item: Item){
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController //We did this method to get access to data there instead of using segue(but we need to change storyboard id (identifier).
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    //MARK: Load Items
    private func loadItems(){
        downloadItemsFromFirebase(withCategoryId: category!.id) { (allItems) in
            print("we have \(allItems.count) items for this category")
            self.itemArray = allItems
            self.tableView.reloadData()
        }
    }

}
extension ItemsTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "There are no items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Come back later or add an item!")
    }
}
