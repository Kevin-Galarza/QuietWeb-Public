//
//  WebsiteSelectionTableViewCell.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/15/24.
//

import UIKit

class WebsiteSelectionTableViewCell: CommonTableViewCell {

    var selectionAccessoryView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    var isCellSelected = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        constructHierarchy()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructHierarchy() {
        contentView.addSubview(selectionAccessoryView)
    }

    private func setupConstraints() {
        selectionAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionAccessoryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            selectionAccessoryView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionAccessoryView.widthAnchor.constraint(equalToConstant: 24),
            selectionAccessoryView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func setSelectionState(isSelected: Bool) {
        isCellSelected = isSelected
        let imageName = isSelected ? "checkmark.circle.fill" : "circle"
        selectionAccessoryView.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        selectionAccessoryView.tintColor = Color.primaryGreen
    }
}


