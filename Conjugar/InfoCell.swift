//
//  InfoCell.swift
//  Conjugar
//
//  Created by Joshua Adams on 7/1/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class InfoCell: UITableViewCell {
  static let identifier = "InfoCell"
  
  private let heading: UILabel = {
    let label = UILabel()
    label.textColor = Colors.yellow
    label.font = Fonts.boldBody
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  } ()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = Colors.black
    addSubview(heading)
    
    addConstraint(NSLayoutConstraint(item: heading, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    addConstraint(NSLayoutConstraint(item: heading, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
  }
  
  func configure(heading: String) {
    self.heading.text = heading
  }
}