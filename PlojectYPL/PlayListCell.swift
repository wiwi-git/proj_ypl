//
//  PlayListCell.swift
//  PlojectYPL
//
//  Created by 위대연 on 9/13/24.
//

import UIKit

class PlayListCell: UITableViewCell {
  static let reuseId: String = "play_list_cell"
  
  lazy var nameLabel: UILabel = {
    let label: UILabel = .init()
    label.font = .systemFont(ofSize: 15)
    label.textColor = .black
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(nameLabel)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    ])
  }
  
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func prepareForReuse() {
      self.nameLabel.text = ""
  }
}
