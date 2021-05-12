//
//  ImageTableViewCell.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    // MARK: - OUTLETS
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewMessage: UIImageView!
    
    // MARK: - VARIABLES
    
    // MARK: - VIEW LIFE CYCLE
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - CONFIGURE CELL
    
    func configureCell(object: DataModel) {
        self.labelTitle.text = object.title
        self.imageViewMessage.image = UIImage.init(data: object.image) ?? UIImage.init(named: "no-image")
    }

}
