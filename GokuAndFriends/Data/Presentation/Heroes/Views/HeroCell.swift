//
//  HeroCell.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import UIKit

class HeroCell: UICollectionViewCell {
    
    static let identifier = String(describing: HeroCell.self)

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureWith(hero: Hero) {
        lbName.text = hero.name
        lbInfo.text = hero.description
    }

}
