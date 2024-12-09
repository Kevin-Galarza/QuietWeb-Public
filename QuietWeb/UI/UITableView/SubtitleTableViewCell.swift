//
//  SubtitleTableViewCell.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/17/24.
//

import UIKit

class SubtitleTableViewCell: CommonTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    func configure(withTitle title: String, subtitle: String, subtitleColor: UIColor) {
        self.textLabel?.text = title
        self.detailTextLabel?.text = subtitle
        self.detailTextLabel?.textColor = subtitleColor
    }
    
    func configureDisclosureAccessory() {
        let image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let accessoryView = UIImageView(image: image)
        accessoryView.tintColor = Color.primaryGreen
        self.accessoryView = accessoryView
    }
}
