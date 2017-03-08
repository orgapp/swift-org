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

fileprivate func matches(_ array: [String]) -> (String) -> Bool {
  return { key in
    return array.contains { $0.lowercased() == key.lowercased() }
  }
}

extension OrgParser {
  
  func isAK(_ key: String) -> Bool {
    return matches(["CAPTION", "HEADER", "NAME", "PLOT", "RESULTS"])(key)
  }
  
  func isIBS(_ key: String) -> Bool {
    return matches(["TODO"])(key)
  }
  
  func dealWithAffiliatedKeyword() throws {
    guard case let (_, Token.setting(key, value)) = tokens.dequeue()! else {
      throw Errors.unexpectedToken("Affiliated Keyword expected")
    }
    
    if isAK(key) {
      attrBuffer = attrBuffer ?? [String : String]()
      attrBuffer![key] = value
    } else {
      orphanAttributes[key] = value
    }
  }
  
  func consumeAffiliatedKeywords() {
    if let attr = attrBuffer {
      orphanAttributes.merge(with: attr)
      attrBuffer = nil
    }
  }
}
