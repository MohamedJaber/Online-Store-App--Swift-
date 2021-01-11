//
//  CategoryCollectionViewCell.swift
//  Online Store
//
//  Created by Mohamed Jaber on 31/12/2020.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func generateCell(_ category: Category){
        nameLabel.text = category.name
        imageView.image = category.image
    }
}
