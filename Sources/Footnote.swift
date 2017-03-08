//
//  Footnote.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 27/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Footnote: NodeContainer {
  public var label: String
  public var content: [Node] = []
  
  public var description: String {
    return "Footnote(content: \(content))"
  }
}

extension OrgParser {
  func parseFootnote() throws -> Footnote {
    guard case let(_, .footnote(label, content)) = tokens.dequeue()! else {
      throw Errors.unexpectedToken("footnote expected")
    }
    
    var footnote = Footnote(label: label, content: [try parseParagraph(content)!])
    var blanks = 0
    footnote = try parse(
      under: footnote,
      breaks: { token in
        switch token {
        case .headline, .footnote: return true
        default: ()
        }
        return false
    }, skips: { token in
      switch token {
      case .blank:
        blanks = blanks + 1
        return blanks == 2
      default: blanks = 0
      }
      return false
    }) as! Footnote
    
    return footnote
  }
}
