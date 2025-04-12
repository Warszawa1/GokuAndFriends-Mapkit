//
//  HeroCell.swift
//  GokuAndFriends
//
//  Created by Ire  Av on 6/4/25.
//

import UIKit
import Kingfisher

class HeroCell: UICollectionViewCell {
    
    static let identifier = String(describing: HeroCell.self)
    
    // MARK: - UI Elements
    private lazy var imgHero: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.shadowColor = UIColor.black.withAlphaComponent(0.7)
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Cell styling
        contentView.backgroundColor = .systemBackground
        
        // Add subviews
        contentView.addSubview(imgHero)
        imgHero.addSubview(nameLabel) // Add the label on top of the image
        
        // Set constraints
        NSLayoutConstraint.activate([
            // Image view fills the cell with small margins
            imgHero.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imgHero.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imgHero.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            imgHero.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Name label at the bottom of the image
            nameLabel.leadingAnchor.constraint(equalTo: imgHero.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: imgHero.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: imgHero.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configureWith(hero: Hero) {
        // Set name
        nameLabel.text = hero.name
        
        // Reset image
        imgHero.image = nil
        let placeholder = UIImage(named: "hero_placeholder") ?? UIImage(systemName: "person.fill")
        imgHero.backgroundColor = .systemGray5 // Placeholder background
        
        // Load the hero's image MANUALLY
//        if let photoURLString = hero.photo, let photoURL = URL(string: photoURLString) {
//            DispatchQueue.global().async {
//                if let imageData = try? Data(contentsOf: photoURL),
//                   let image = UIImage(data: imageData) {
//                    DispatchQueue.main.async {
//                        self.imgHero.image = image
//                    }
//                }
//            }
//        }
        // Use Kingfisher to load and cache the image
        if let photoURLString = hero.photo, let photoURL = URL(string: photoURLString) {
            imgHero.kf.setImage(
                with: photoURL,
                placeholder: placeholder,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            imgHero.image = placeholder
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel any ongoing downloads when cell is reused
        imgHero.kf.cancelDownloadTask()
        imgHero.image = nil
        nameLabel.text = nil
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
