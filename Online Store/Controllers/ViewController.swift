//
//  ViewController.swift
//  Online Store
//
//  Created by Mohamed Jaber on 06/01/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text=""
         var index=0.0
         let titleText="Jabra Store🔱"
         for letter in titleText{
             Timer.scheduledTimer(withTimeInterval: 0.1*index, repeats: false) { (timer) in
                 self.titleLabel.text?.append(letter)
             }
             index+=1
         }
    }
    

  
}
