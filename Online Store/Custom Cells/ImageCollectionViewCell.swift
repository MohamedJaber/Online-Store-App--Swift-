//
//  ImageCollectionViewCell.swift
//  Online Store
//
//  Created by Mohamed Jaber on 02/01/2021.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    func setupImageWith(itemImage: UIImage){
        imageView.image = itemImage 
    }
}
