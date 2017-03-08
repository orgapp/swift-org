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
  
  fileprivate func parseFootnoteContent(under footnote: Footnote, strikes: Int = 0) throws -> Footnote {
    guard let (_, token) = tokens.peek() else {
      return footnote
    }
    var newFootnote = footnote
    var content: Node? = nil
    var newStrikes = strikes
    switch token {
    case .blank:
      newStrikes += 1
      if newStrikes == 2 { return footnote }
      _ = tokens.dequeue()
    case .headline, .footnote:
      return footnote
    default:
      content = try parseTheRest()
      newStrikes = 0
    }
    
    if let newContent = content {
      newFootnote.content.append(newContent)
    }
    
    return try parseFootnoteContent(under: newFootnote, strikes: newStrikes)
  }
  
  func parseFootnote() throws -> Footnote {
    guard case let(_, .footnote(label, content)) = tokens.dequeue()! else {
      throw Errors.unexpectedToken("footnote expected")
    }
    
    let footnote = Footnote(label: label, content: [try parseParagraph(content)!])
    return try parseFootnoteContent(under: footnote)
  }
}
