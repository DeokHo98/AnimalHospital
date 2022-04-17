//
//  DetailCell.swift
//  AnimalHospital
//
//  Created by 정덕호 on 2022/04/15.
//

import UIKit

class DetailCell: UITableViewCell {
    static let identifier = "detailcell"
    
    //MARK: - 속성

    
     let cellLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
     let cellImage: UIImageView = {
        let iv = UIImageView()
        iv.setWidth(25)
        iv.setHeight(25)
        iv.tintColor = .lightGray
        return iv
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cellImage,cellLabel])
        stack.axis = .horizontal
        stack.spacing = 15
        return stack
    }()
        
            
        
      
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(stack)
        stack.anchor(leading: self.leadingAnchor, trailing: self.trailingAnchor,paddingLeading: 20,paddingTrailing: 20)
        stack.centerY(inView: self)
        
    }

}
