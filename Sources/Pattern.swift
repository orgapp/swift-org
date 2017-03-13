//
//  Pattern.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 13/03/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

struct Match {
  let pattern: String
  let captures: [Int : String]?
  let expression: RegularExpression
  
  init(_ _pattern: String,
       options: RegularExpression.Options = [],
       captures _captures: [Int : String]? = nil) {
    pattern = _pattern
    captures = _captures
    expression = try! RegularExpression(
      pattern: pattern, options: options)
  }
}

struct Pattern {
  let name: String
  let match: Match
  
  init(_ _name: String,
       match _match: String,
       options: RegularExpression.Options = [],
       captures: [Int : String]? = nil) {
    name = _name
    match = Match(_match, options: options, captures: captures)
  }
}
