//
//  ItemTableViewCell.swift
//  Online Store
//
//  Created by Mohamed Jaber on 01/01/2021.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    //MARK: IBOutlets
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func generateCell(_ item: Item) {
        nameLabel.text = item.name
        priceLabel.text = convertToCurrency(Double(item.price)!)
        priceLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.text = item.description

        if item.imageLinks != nil && item.imageLinks.count>0{
            downloadImages(imagesUrl: [item.imageLinks.first!]) { (images) in
                self.itemImageView.image = images.first as? UIImage
            }
        }
    }
}
