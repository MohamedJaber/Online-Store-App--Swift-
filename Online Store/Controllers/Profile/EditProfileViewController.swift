//
//  EditProfileViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 03/01/2021.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var logoutButton: UIButton!
    //MARK: - Variables
    let hud = JGProgressHUD(style: .dark)
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        nameTextField.layer.borderColor = UIColor.darkGray.cgColor
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 6
        nameTextField.layer.masksToBounds = true
        surnameTextField.layer.borderColor = UIColor.darkGray.cgColor
        surnameTextField.layer.borderWidth = 1
        surnameTextField.layer.cornerRadius = 6
        surnameTextField.layer.masksToBounds = true
        addressTextField.layer.borderColor = UIColor.darkGray.cgColor
        addressTextField.layer.borderWidth = 1
        addressTextField.layer.cornerRadius = 6
        addressTextField.layer.masksToBounds = true
        logoutButton.layer.borderColor = UIColor.darkGray.cgColor
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.cornerRadius = 6
        logoutButton.layer.masksToBounds = true
        super.viewDidLoad()
        loadExistingUserInfo()
    }
    
    //MARK: - IBActions
    
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if textFieldsHaveText(){
            
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADDRESS : addressTextField.text!] as [String : Any]
            
            updateCurrentUserInFirebase(withValues: withValues) { (error) in
                if error != nil {
                    self.initJGProgressHUD(withText: "There was an error: \(String(describing: error?.localizedDescription))", typeOfIndicator: JGProgressHUDErrorIndicatorView(), delay: 2.0)
                    
                } else {
                    self.initJGProgressHUD(withText: "Fields were updated!", typeOfIndicator: JGProgressHUDSuccessIndicatorView(), delay: 2.0)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            initJGProgressHUD(withText: "All fields must have text!", typeOfIndicator: JGProgressHUDErrorIndicatorView(), delay: 2.0)
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        logoutUser()
    }
    
    //MARK: - Update UI
    private func loadExistingUserInfo(){
        if MUser.currentUser() != nil {
            let currentUser = MUser.currentUser()!
            
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    
    //MARK: - JGProgress HUD creator
    private func initJGProgressHUD(withText: String?,typeOfIndicator: JGProgressHUDImageIndicatorView, delay: Double){
        //creating a JGProgressHUD
        self.hud.textLabel.text = withText
        self.hud.indicatorView = typeOfIndicator
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: delay)
    }
    
    
    //MARK: - Helper functions
    private func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool{
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logoutUser(){
        MUser.logoutCurrentUser { (error) in
            if error != nil {
                print("error logging out!: \(error?.localizedDescription)")
            } else {
                print("Logged out")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
