//
//  Conjugator.swift
//  Conjugar
//
//  Created by Joshua Adams on 3/31/17.
//  Copyright © 2017 Josh Adams. All rights reserved.
//

import Foundation

class Conjugator {
  static let defective = "df"
  static let parent = "pe"
  static let trim = "tr"
  static let stem = "st"
  static let sharedInstance = Conjugator()
  
  var verbs: [String: [String: String]] = [:]
  
  init() {
    //verbs = VerbLoader.loadVerbs()
    verbs = VerbParser().parse()
  }
  
  func verbArray() -> [String] {
    return Array(verbs.keys).sorted()
  }
  
  func parent(infinitive: String) -> String? {
    if let verb = verbs[infinitive], let parent = verb[Conjugator.parent] {
      return parent
    }
    else {
      return nil
    }
  }
  
  func verbType(infinitive: String) -> VerbType {
    let index = infinitive.index(infinitive.endIndex, offsetBy: -2)
    let ending = infinitive.substring(from: index)
    if let verb = verbs[infinitive] {
      if verb[Conjugator.parent] == nil {
        return typeForEnding(ending)
      }
      else {
        return .irregular
      }
    }
    else {
      return typeForEnding(ending)
    }
  }
  
  private func typeForEnding(_ ending: String) -> VerbType {
    if ending == "ar" {
      return .regularAr
    }
    else if ending == "er" {
      return .regularEr
    }
    else {
      return .regularIr
    }
  }
  
  func isDefective(infinitive: String) -> Bool {
    if let verb = verbs[infinitive] {
      if verb[PersonNumber.firstSingular.rawValue] != nil || verb[PersonNumber.secondSingular.rawValue] != nil || verb[PersonNumber.thirdSingular.rawValue] != nil || verb[PersonNumber.firstPlural.rawValue] != nil || verb[PersonNumber.secondPlural.rawValue] != nil || verb[PersonNumber.thirdPlural.rawValue] != nil {
        return true
      }
      else {
        return false
      }
    }
    else {
      return false
    }
  }
  
  func conjugate(infinitive: String, tense: Tense, personNumber: PersonNumber, region: Region = .spain) -> Result<String, ConjugatorError> {
    if infinitive.characters.count < 2 {
      return .failure(.tooShort)
    }
    if personNumber == .firstSingular && (tense == .imperativo || tense == .imperativoNegativo) {
      return .failure(.noFirstPersonSingularImperative)
    }
    let index = infinitive.index(infinitive.endIndex, offsetBy: -2)
    let ending = infinitive.substring(from: index)
    if !["ar", "er", "ir"].contains(ending) {
      return .failure(.invalidEnding(ending))
    }
    if (tense == .gerundio || tense == .participio || tense == .talloFuturo) && personNumber != .none {
      return .failure(.noSuchConjugation(personNumber))
    }
    if (tense != .gerundio && tense != .participio && tense != .talloFuturo) && personNumber == .none {
      return .failure(.personNumberAbsent(tense))
    }
    
    if verbs[infinitive] == nil {
      let stem = infinitive.substring(to: index)
      var verb:[String: String] = [:]
      if ending == "ar" {
        verb[Conjugator.parent] = "hablar"
        verb[Conjugator.stem] = stem
        verb[Conjugator.trim] = "habl"
      }
      else if ending == "er" {
        verb[Conjugator.parent] = "comer"
        verb[Conjugator.stem] = stem
        verb[Conjugator.trim] = "com"
      }
      else { // if ending == "ir"
        verb[Conjugator.parent] = "subir"
        verb[Conjugator.stem] = stem
        verb[Conjugator.trim] = "sub"
      }
      verbs[infinitive] = verb
    }
    return conjugateRecursively(infinitive: infinitive, tense: tense, personNumber: personNumber, region: region)
  }
  
  private func conjugateRecursively(infinitive: String, tense: Tense, personNumber: PersonNumber, region: Region = .spain) -> Result<String, ConjugatorError> {
    var verb = verbs[infinitive]!
    var modifiedPersonNumber = personNumber
    if personNumber == .secondPlural && region == .latinAmerica {
      modifiedPersonNumber = .thirdPlural
    }
    if let defective = verb[modifiedPersonNumber.rawValue], defective == Conjugator.defective {
      return .success(Conjugator.defective)
    }
    let conjugationKey: String
    if tense == .gerundio || tense == .participio || tense == .talloFuturo {
      conjugationKey = tense.rawValue
    }
    else {
      conjugationKey = modifiedPersonNumber.rawValue + tense.rawValue
    }
    if tense == .talloFuturo && verb[conjugationKey] == nil {
      return .success(infinitive)
    }
    if let conjugation = verb[conjugationKey] {
      return .success(conjugation)
    }
    else if [.presenteDeIndicativo, .preterito, .imperfectoDeIndicativo, .presenteDeSubjuntivo, .gerundio, .participio].contains(tense) {
      let parentConjugation = conjugateRecursively(infinitive: verb[Conjugator.parent]!, tense: tense, personNumber: personNumber, region: region).value!
      let trim: String
      let stem: String
      if (tense == .futuroDeIndicativo || tense == .condicional) && verb[Tense.talloFuturo.rawValue] != nil {
        trim = verb[Conjugator.parent]!
        stem = verb[Tense.talloFuturo.rawValue]!
      }
      else {
        trim = verb[Conjugator.trim]!
        stem = verb[Conjugator.stem]!
      }
      var conjugation: String
      if trim == "" {
        conjugation = stem + parentConjugation
      }
      else {
        conjugation = parentConjugation.replaceFirstOccurence(of: trim, with: stem)
      }
      verb[conjugationKey] = conjugation
      verbs[infinitive] = verb
      return .success(conjugation)
    }
    else if [Tense.futuroDeIndicativo, Tense.condicional].contains(tense) {
      let stem = verb[Tense.talloFuturo.rawValue] ?? infinitive
      return .success(stem + endingFor(tense: tense, personNumber: personNumber))
    }
    else if [Tense.imperfectoDeSubjuntivo1, Tense.imperfectoDeSubjuntivo2, Tense.futuroDeSubjuntivo].contains(tense) {
      let stemWithRon: String
      if let defective = verb[PersonNumber.thirdPlural.rawValue], defective == Conjugator.defective {
        let parentStem = conjugateRecursively(infinitive: verb[Conjugator.parent]!, tense: Tense.preterito, personNumber: PersonNumber.thirdPlural, region: region).value!
        let trim = verb[Conjugator.trim]!
        let stem = verb[Conjugator.stem]!
        if trim == "" {
          stemWithRon = stem + parentStem
        }
        else {
          stemWithRon = parentStem.replaceFirstOccurence(of: trim, with: stem)
        }
      }
      else {
        stemWithRon = conjugateRecursively(infinitive: infinitive, tense: Tense.preterito, personNumber: PersonNumber.thirdPlural, region: region).value!
      }
      let endIndex = stemWithRon.index(stemWithRon.endIndex, offsetBy: -3)
      let stemRange = stemWithRon.startIndex ..< endIndex
      var stem = stemWithRon.substring(with: stemRange)
      if personNumber == .firstPlural {
        let lastCharIndex = stem.index(stem.endIndex, offsetBy: -1)
        let lastChar = stem.substring(from: lastCharIndex)
        let accentedLastChar: String
        if lastChar == "a" {
          accentedLastChar = "á"
        }
        else {
          accentedLastChar = "é"
        }
        let stemWithoutLastChar = stem.substring(to: lastCharIndex)
        stem = stemWithoutLastChar + accentedLastChar
      }
      return .success(stem + endingFor(tense: tense, personNumber: personNumber))
    }
    else if [.perfectoDeIndicativo, .preteritoAnterior, .pluscuamperfectoDeIndicativo, .futuroPerfecto, .condicionalCompuesto, .perfectoDeSubjuntivo, .pluscuamperfectoDeSubjuntivo1, .pluscuamperfectoDeSubjuntivo2, .futuroPerfectoDeSubjuntivo].contains(tense) {
      let haberTenseResult = tense.haberTenseForCompoundTense()
      let haberTense: Tense
      switch haberTenseResult {
      case let .success(auxiliaryTense):
        haberTense = auxiliaryTense
      case let .failure(.noHaberForm(form)):
        return .failure(.tenseNotImplemented(form))
      }
      let auxiliary = conjugateRecursively(infinitive: Tense.auxiliary, tense: haberTense, personNumber: personNumber, region: region).value!
      let participle = conjugateRecursively(infinitive: infinitive, tense: .participio, personNumber: .none, region: region).value!
      return .success(auxiliary + " " + participle)
    }
    else if tense == .imperativo {
      if personNumber == .firstSingular {
        return .failure(.noFirstPersonSingularImperative)
      }
      if [.thirdSingular, .firstPlural, .thirdPlural].contains(personNumber) {
        return .success(conjugateRecursively(infinitive: infinitive, tense: .presenteDeSubjuntivo, personNumber: personNumber, region: region).value!)
      }
      else {
        if personNumber == .secondSingular {
          if let conjugation = verbs[infinitive]?[PersonNumber.secondSingular.rawValue + Tense.imperativo.rawValue] {
            return .success(conjugation)
          }
          else {
            let stemWithS = conjugateRecursively(infinitive: infinitive, tense: .presenteDeIndicativo, personNumber: .secondSingular, region: region).value!
            return .success(stemWithS.substring(to: stemWithS.index(stemWithS.endIndex, offsetBy: -1)))
          }
        }
        else {
          return .success(infinitive.substring(to: infinitive.index(infinitive.endIndex, offsetBy: -1)) + "d")
        }
      }
    }
    else if tense == .imperativoNegativo {
      if personNumber == .firstSingular {
        return .failure(.noFirstPersonSingularImperative)
      }
      return .success("no " + conjugateRecursively(infinitive: infinitive, tense: .presenteDeSubjuntivo, personNumber: personNumber, region: region).value!)
    }
    else {
      return .failure(.tenseNotImplemented(tense))
    }
  }
  
  private func endingFor(tense: Tense, personNumber: PersonNumber) -> String {
    switch personNumber {
    case .firstSingular:
      switch tense {
      case .imperfectoDeSubjuntivo1:
        return "ra"
      case .imperfectoDeSubjuntivo2:
        return "se"
      case .futuroDeSubjuntivo:
        return "re"
      case .futuroDeIndicativo:
        return "é"
      case .condicional:
        return "ía"
      default:
        return ""
      }
    case .secondSingular:
      switch tense {
      case .imperfectoDeSubjuntivo1:
        return "ras"
      case .imperfectoDeSubjuntivo2:
        return "ses"
      case .futuroDeSubjuntivo:
        return "res"
      case .futuroDeIndicativo:
        return "ás"
      case .condicional:
        return "ías"
      default:
        return ""
      }
    case .thirdSingular:
      switch tense {
      case .imperfectoDeSubjuntivo1:
        return "ra"
      case .imperfectoDeSubjuntivo2:
        return "se"
      case .futuroDeSubjuntivo:
        return "re"
      case .futuroDeIndicativo:
        return "á"
      case .condicional:
        return "ía"
      default:
        return ""
      }
    case .firstPlural:
      switch tense {
      case .imperfectoDeSubjuntivo1:
        return "ramos"
      case .imperfectoDeSubjuntivo2:
        return "semos"
      case .futuroDeSubjuntivo:
        return "remos"
      case .futuroDeIndicativo:
        return "emos"
      case .condicional:
        return "íamos"
      default:
        return ""
      }
    case .secondPlural:
      switch tense {
      case .imperfectoDeSubjuntivo1:
        return "rais"
      case .imperfectoDeSubjuntivo2:
        return "seis"
      case .futuroDeSubjuntivo:
        return "reis"
      case .futuroDeIndicativo:
        return "éis"
      case .condicional:
        return "íais"
      default:
        return ""
      }
    case .thirdPlural:
      switch tense {
      case .imperfectoDeSubjuntivo1:
        return "ran"
      case .imperfectoDeSubjuntivo2:
        return "sen"
      case .futuroDeSubjuntivo:
        return "ren"
      case .futuroDeIndicativo:
        return "án"
      case .condicional:
        return "ían"
      default:
        return ""
      }
    case .none:
      return ""
    }
  }
}