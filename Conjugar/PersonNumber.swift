//
//  PersonNumber.swift
//  Conjugar
//
//  Created by Joshua Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import Foundation

enum PersonNumber: String {
  case firstSingular = "fs"
  case firstPlural = "fp"
  case secondSingular = "ss"
  case secondPlural = "sp"
  case thirdSingular = "ts"
  case thirdPlural = "tp"
  case none = "no"
  
  func endingForFuturoDeSubjuntivo() -> String {
    switch self {
    case .firstSingular:
      return "re"
    case .secondSingular:
      return "res"
    case .thirdSingular:
      return "re"
    case .firstPlural:
      return "remos"
    case .secondPlural:
      return "reis"
    case .thirdPlural:
      return "ren"
    case .none:
      return ""
    }
  }
  
  var pronoun: String {
    switch self {
    case .firstSingular:
      return "yo"
    case .secondSingular:
      return "tú"
    case .thirdSingular:
      return "él"
    case .firstPlural:
      return "nosotros"
    case .secondPlural:
      return "vosotros"
    case .thirdPlural:
      return "ellas"
    case .none:
      return ""
    }
  }
}
