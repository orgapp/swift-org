//
//  Affiliatable.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 6/03/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

public protocol Affiliatable {
  var attributes: [String : String] { get set }
}

extension OrgParser {
  func dealWithAffiliatedKeyword() throws {
    guard case let (_, Token.setting(key, value)) = tokens.dequeue()! else {
      throw Errors.unexpectedToken("Affiliated Keyword expected")
    }
    
    let isAK = ["CAPTION", "HEADER", "NAME", "PLOT", "RESULTS"]
      .contains { $0.lowercased() == key.lowercased() }
    
    if isAK {
      attrBuffer = attrBuffer ?? [String : String]()
      attrBuffer![key] = value
    } else {
      document.attributes[key] = value
    }
  }
  
  func consumeAffiliatedKeywords() {
    if let attr = attrBuffer {
      document.attributes.merge(with: attr)
      attrBuffer = nil
    }
  }
}
