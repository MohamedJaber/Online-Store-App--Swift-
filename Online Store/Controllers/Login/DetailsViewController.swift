//
//  DetailsViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 03/01/2021.
//

import UIKit
import JGProgressHUD

class DetailsViewController: UIViewController {

    //MARK: - IBOutlets

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    //MARK: - Variables
    let hud: JGProgressHUD = JGProgressHUD(style: .dark)

    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        doneButton.layer.borderColor = UIColor.darkGray.cgColor
        doneButton.layer.borderWidth = 1
        doneButton.layer.cornerRadius = 6
        doneButton.layer.masksToBounds = true
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_ :)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_ :)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_ :)), for: UIControl.Event.editingChanged)

    }
    
    
    //MARK: - IBActions
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishOnboarding()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        updateDoneButtonStatus()
    }
    
    
    //MARK: - Helper functions
    //EXPLANATION: - checking if the textfields have any text
    private func updateDoneButtonStatus(){
        if nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "" {
            doneButton.backgroundColor = .none
            doneButton.isEnabled = true
        } else {
            doneButton.backgroundColor = .lightGray
            doneButton.isEnabled = false
        }
    }
    private func finishOnboarding() {
        let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kONBOARD : true, kFULLADDRESS : addressTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
        updateCurrentUserInFirebase(withValues: withValues) { (error) in
            if error == nil {
                self.initJGProgressHUD(withText: "Updated details successfully!", typeOfIndicator: JGProgressHUDSuccessIndicatorView(), delay: 2.0)
            } else {
                print("Error updating user: ", error?.localizedDescription)
                self.initJGProgressHUD(withText: "Error: \(error?.localizedDescription)", typeOfIndicator: JGProgressHUDErrorIndicatorView(), delay: 2.0)
            }
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
    


}
