//
//  ConjugationCell.swift
//  Conjugar
//
//  Created by Joshua Adams on 5/7/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import UIKit

class ConjugationCell: UITableViewCell {
  static let identifier = "ConjugationCell"
  
  private let conjugation: UILabel = {
    let label = UILabel()
    label.textColor = Colors.yellow
    label.font = Fonts.smallCell
    label.enableAutoLayout()
    return label
  } ()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConjugationCell.tap(_:))))
    selectionStyle = .none
    backgroundColor = Colors.black
    addSubview(conjugation)
    conjugation.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    conjugation.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
  }
  
  func configure(tense: Tense, personNumber: PersonNumber, conjugation: String) {
    var conjugation = conjugation
    if conjugation == Conjugator.defective {
      self.conjugation.text = ""
    }
    else {
      if tense == .imperativoPositivo || tense == .imperativoNegativo {
        conjugation = "¡" + conjugation + "!"
      }
      else {
        conjugation = personNumber.pronoun + " " + conjugation
      }
      self.conjugation.attributedText = conjugation.conjugatedString
    }
  }
  
  @objc func tap(_ sender: UITapGestureRecognizer) {
    Utterer.utter(conjugation.attributedText?.string ?? conjugation.text!)
  }
}
