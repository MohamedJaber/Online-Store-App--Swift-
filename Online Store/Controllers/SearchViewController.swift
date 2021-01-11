//
//  SearchViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 03/01/2021.
//

import UIKit
import NVActivityIndicatorView
import EmptyDataSet_Swift
import SideMenu

class SearchViewController: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seachOptionView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButtonOutlet: UIButton!

    //MARK: - Variables
    var searchResults: [Item] = []
    var activityIndicator: NVActivityIndicatorView?
    var menu: UISideMenuNavigationController?
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        menu = UISideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: false)
        SideMenuManager.default.menuLeftNavigationController = menu
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.view)
        searchButtonOutlet.layer.borderColor = UIColor.gray.cgColor
        searchButtonOutlet.layer.borderWidth = 1
        searchButtonOutlet.layer.cornerRadius = 6
        searchButtonOutlet.layer.masksToBounds = true
        searchTextField.layer.borderColor = UIColor.gray.cgColor
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.cornerRadius = 6
        searchTextField.layer.masksToBounds = true
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .pacman, color: .black, padding: nil)    }

    //MARK: - IBActions
    @IBAction func sideMenuButton(_ sender: UIBarButtonItem) {
        present(menu!, animated: true)
    }
    
    @IBAction func showSearchBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        showSearchField()
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        if searchTextField.text != "" {
            searchInFirebase(forName: searchTextField.text!)
            emptyTextField()
            animateSearchOptionIn()
            dismissKeyboard()
        }
    }
    //MARK: - Search in database
    private func searchInFirebase(forName: String){
        showLoadingIndicator()
        searchAlgolia(searchString: forName) { (itemIDs) in
            downloadItemsFromFirebaseByItemID(withIDs: itemIDs) { (allItems) in
                self.searchResults = allItems
                self.tableView.reloadData()
                
                self.hideLoadingIndicator()
            }
        }
    }

    
    //MARK: - Helper functions
    private func emptyTextField(){
        searchTextField.text = ""
    }
    
    private func dismissKeyboard(){
        self.view.endEditing(true)
    }

    @objc func textFieldDidChange (_ textField: UITextField){
        //EXPLANATION: - if the textField has any kind of text, it will be automatically enabled
        searchButtonOutlet.isEnabled = textField.text != ""
        
        if searchButtonOutlet.isEnabled {
            searchButtonOutlet.backgroundColor = .lightGray
        } else {
            disableSearchButton()
        }
    }
    
    private func disableSearchButton(){
        searchButtonOutlet.isEnabled = false
        searchButtonOutlet.backgroundColor = .lightGray
    }
    
    private func showSearchField(){
        disableSearchButton()
        emptyTextField()
        animateSearchOptionIn()
    }
    
    //MARK: - Animations
    private func animateSearchOptionIn() {
        UIView.animate(withDuration: 0.5) {
            //EXPLANATION: - handling whether the searchOptionView is hidden or not
            self.seachOptionView.isHidden = !self.seachOptionView.isHidden
        }
    }
    
    //MARK: - Activity indicator
    private func showLoadingIndicator() {
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    
    //MARK: - Navigation
    private func showItemView(withItem: Item){
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
        
    }
    
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
        cell.generateCell(searchResults[indexPath.row])
        
        return cell
    }
    
    //MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //EXPLANATION: - opening the View that contains the selected item
        showItemView(withItem: searchResults[indexPath.row])
    }
    
}
extension SearchViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "There are no items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Come back later or ajust your search criteria!")
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        return UIImage(named: "search")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return NSAttributedString(string: "Start searching!...")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        showSearchField()
    }
}
