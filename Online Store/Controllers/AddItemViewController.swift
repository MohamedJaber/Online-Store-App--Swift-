//
//  AddItemViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 31/12/2020.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView

class AddItemViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBOutlet weak var cameraButton: UIButton!
    //MARK: Vars
    var category: Category!
    var itemImages: [UIImage?] = []
    var gallery: GalleryController!
    var hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(category.id)
        titleTextField.layer.borderColor = UIColor.darkGray.cgColor
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.cornerRadius = 6
        titleTextField.layer.masksToBounds = true
        priceTextField.layer.borderColor = UIColor.darkGray.cgColor
        priceTextField.layer.borderWidth = 1
        priceTextField.layer.cornerRadius = 6
        priceTextField.layer.masksToBounds = true
        descriptionTextField.layer.borderColor = UIColor.darkGray.cgColor
        descriptionTextField.layer.borderWidth = 1
        descriptionTextField.layer.cornerRadius = 6
        descriptionTextField.layer.masksToBounds = true
        cameraButton.layer.borderColor = UIColor.darkGray.cgColor
        cameraButton.layer.borderWidth = 1
        cameraButton.layer.cornerRadius = 6
        cameraButton.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2-30, y: self.view.frame.height/2-30, width: 60, height: 60), type: .pacman, color: .black, padding: nil)
    }
    
    //MARK: Actions
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        dismissKeyboard()
        if fieldsAreCompleted(){
           saveToFirebase()
        }
        else {
            print("Error all fields are required")
            self.hud.textLabel.text = "All fields are required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    @IBAction func cameraButtonPressed(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    @IBAction func bacckgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    
    //MARK: Helper functions
    private func fieldsAreCompleted()->Bool
    {
        return (titleTextField.text != "" && priceTextField.text != "" && descriptionTextField.text != "")
    }
    private func popTheView(){
        self.navigationController?.popViewController(animated: true)
    }
    private func dismissKeyboard(){
        self.view.endEditing(false)
    }
    private func saveToFirebase(){
        showLoadingIndicator()
        let item = Item()
        item.id = UUID().uuidString
        item.categoryId = category.id
        item.name = titleTextField.text
        item.description = descriptionTextField.text
        item.price = priceTextField.text
        if itemImages.count > 0 {
            uploadImages(images: itemImages, itemId: item.id) { (imageLinkArray) in
                item.imageLinks = imageLinkArray
                saveItemToFirestore(item)
                saveItemToAlgolia(item: item)
                self.hideLoadingIndicator()
                self.popTheView()
            }
        }
        else {
            saveItemToFirestore(item)
            saveItemToAlgolia(item: item)
            self.hideLoadingIndicator()
            popTheView()
        }
    }
    
    //MARK: Activity Indicator
    private func showLoadingIndicator(){
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    private func hideLoadingIndicator(){
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }}
    //MARK: Show Gallery
    private func showImageGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.cameraTab, .imageTab]
        Config.Camera.imageLimit = 6
        self.present(self.gallery, animated: true, completion: nil)
    }
}

extension AddItemViewController: GalleryControllerDelegate{
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            Image.resolve(images: images) { (resolvedImages) in
            self.itemImages = resolvedImages
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
