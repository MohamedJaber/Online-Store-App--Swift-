//
//  ItemViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 02/01/2021.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    
    //MARK: - Vars
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    private let cellHeight: CGFloat = 196.0
    private let itemsPerRow: CGFloat = 1
    //MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.layer.borderColor = UIColor.darkGray.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 6
        descriptionTextView.layer.masksToBounds = true
        setupUI()
        downloadPictures()
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "addToBasket"), style: .plain, target: self, action: #selector(self.addToBasketPressed))]
    }
    //MARK: - Download Pics
    
    private func downloadPictures(){
        if item != nil && item.imageLinks != nil {
            downloadImages(imagesUrl: item.imageLinks){ (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Setup UI
    
    private func setupUI(){
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(Double(item.price)!)
            descriptionTextView.text = item.description
        }
    }
    @objc func backAction(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)}                                 
    }
    @objc func addToBasketPressed(){
        //EXPLANATION: - If the user is logged in, then the application
        //EXPLANATION: - will add the item in the basket
        if MUser.currentUser() != nil {
            downloadBasketFromFirestore(MUser.currentID()) { (basket) in
                if basket == nil {
                    self.createNewBasket()
                } else {
                    //appending another item to the existing basket
                    basket!.itemIds.append(self.item.id)
                    //updating the itemIDs exsiting in Firebase for the existing basket
                    self.updateBasket(basket: basket!, withValues: [kITEMIDS : basket!.itemIds!])
                }
            }
        } else {
            //EXPLANATION: - else if the user is not logged in
            //EXPLANATION: - the login view will be presented
            showLoginView()
        }
    }
    //MARK: - Add to basket
    private func createNewBasket(){
        //checking if the specific user has a basket, uses updateBasket
        //else a basket is created
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = MUser.currentID()
        newBasket.itemIds = [self.item.id]
        saveBasketToFirestore(newBasket)
        initJGProgressHUD(withText: "Added to basket!",typeOfIndicator: JGProgressHUDSuccessIndicatorView() ,delay: 2.0)

    }
    //MARK: - Update basket
    private func updateBasket(basket: Basket, withValues: [String : Any]){
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if error != nil {
                //there is an error so an error will be shown
                self.initJGProgressHUD(withText: "There was an error while updating basket: \(error!.localizedDescription)"
                    ,typeOfIndicator: JGProgressHUDErrorIndicatorView(), delay: 2.0)
            } else {
                self.initJGProgressHUD(withText: "Added to basket!", typeOfIndicator: JGProgressHUDSuccessIndicatorView(), delay: 2.0)
            }
        }
    }
    

    //MARK: - Show login view
    private func showLoginView(){
        let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
        
    }
    
    //MARK: - JGProgress HUD creator
    private func initJGProgressHUD(withText: String?,typeOfIndicator: JGProgressHUDImageIndicatorView, delay: Double){
        //creating a JGProgressHUD
        self.hud.textLabel.text = withText
        self.hud.indicatorView = typeOfIndicator
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: delay)
    }
}
extension ItemViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width - sectionInsets.left
        return CGSize(width: availableWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1 : itemImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        if itemImages.count > 0 {
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
        }
        return cell
    }
}
