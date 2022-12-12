//
//  CustomTableViewCell.swift
//  MealTrkr
//
//  Created by Usman Qazi on 12/11/22.
//

import UIKit

class CustomTableViewCell : UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
//    static let identifier = "CustomTableViewCell"
//
//    private let _button: UIButton = {
//        let _button = UIButton()
//        _button.backgroundColor = .red
//        _button.setTitle("Delete", for: .normal)
//        return _button
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        _button.frame = CGRect(x: 5, y: 5, width: 100, height: contentView.frame.size.height-10)
//    }
}
