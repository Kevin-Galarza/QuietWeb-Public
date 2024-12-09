//
//  SubtitleTableViewCell.swift
//  DistractionBlockerPlus
//
//  Created by Kevin Galarza on 7/11/24.
//

import UIKit

class BlocklistTableViewCell: CommonTableViewCell {

    var selectionAccessoryView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.detailTextLabel?.textColor = UIColor.systemGray
        constructHierarchy()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructHierarchy() {
        addSubview(selectionAccessoryView)
    }

    private func setupConstraints() {
        selectionAccessoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionAccessoryView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            selectionAccessoryView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionAccessoryView.widthAnchor.constraint(equalToConstant: 24),
            selectionAccessoryView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func setSelectionState(isSelected: Bool) {
        let imageName = isSelected ? "checkmark.circle.fill" : "circle"
        selectionAccessoryView.image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        selectionAccessoryView.tintColor = Color.primaryGreen
    }
}
