//
//  HeroCell.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import UIKit

class HeroCell: UICollectionViewCell {
    
    static let identifier = String(describing: HeroCell.self)

    @IBOutlet weak var imgHero: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Cell styling
        contentView.backgroundColor = .systemBackground
        
        // Add a subtle shadow to the cell
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        
        // Image view styling
        imgHero.contentMode = .scaleAspectFill
        imgHero.clipsToBounds = true
        imgHero.layer.cornerRadius = 10
        imgHero.backgroundColor = .systemGray5 // Placeholder background
        
        // Name label styling
        lbName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbName.textColor = .label
        
        // Info label styling
        lbInfo.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbInfo.textColor = .secondaryLabel
        lbInfo.numberOfLines = 2
    }
    
    func configureWith(hero: Hero) {
        // Set text
        lbName.text = hero.name
        lbInfo.text = hero.description
        
        // Reset image with placeholder
        if let placeholder = UIImage(named: "hero_placeholder") {
            imgHero.image = placeholder
        } else {
            imgHero.backgroundColor = .systemGray5
        }
        
        // Add animation to image load
        UIView.transition(with: imgHero, duration: 0.3, options: .transitionCrossDissolve, animations: {
            // Empty animation body - we'll set the image inside the completion of the download
        }, completion: nil)
        
        // Load the hero's image
        if let photoURLString = hero.photo, let photoURL = URL(string: photoURLString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: photoURL),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        // Fade in the new image
                        UIView.transition(with: self.imgHero, duration: 0.3, options: .transitionCrossDissolve, animations: {
                            self.imgHero.image = image
                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the cell's properties
        if let placeholder = UIImage(named: "hero_placeholder") {
            imgHero.image = placeholder
        } else {
            imgHero.backgroundColor = .systemGray5
        }
        lbName.text = nil
        lbInfo.text = nil
    }
}
//import UIKit
//
//class HeroCell: UICollectionViewCell {
//    
//    static let identifier = String(describing: HeroCell.self)
//
//    @IBOutlet weak var lbName: UILabel!
//    @IBOutlet weak var lbInfo: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//    
//    func configureWith(hero: Hero) {
//        lbName.text = hero.name
//        lbInfo.text = hero.description
//    }
//
//}
