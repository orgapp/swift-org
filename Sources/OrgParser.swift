//
//  Parser.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum Errors: Error {
  case unexpectedToken(String)
  case cannotFindToken(String)
  case illegalNodeForContainer(String)
}

public class OrgParser {
  // MARK: properties
  var tokens: Queue<TokenInfo>!
  var document: OrgDocument!
  var attrBuffer: [String : String]?
  var orphanAttributes = [String : String]()
  public var defaultTodos: [[String]]
  
  // MARK: init
  public init(defaultTodos: [[String]] = [["TODO"], ["DONE"]]) {
    self.defaultTodos = defaultTodos
  }
  
  func reset() {
    attrBuffer = nil
    orphanAttributes = [String : String]()
    tokens = nil
  }
    
  /// look ahead for matching tokens
  ///
  /// - Parameters:
  ///   - match: matcher
  ///   - found: callback when found the target
  ///   - notYet: callback for not yet
  ///   - Failed: failed to find the match
  /// - Throws: Lexer Error
  func lookAhead(
    match: (Token) -> Bool,
    found: (Token) -> Void,
    notYet: (TokenMeta) -> Void,
    failed: () throws -> Void) throws {
    
    guard let (meta, token) = tokens.dequeue() else {
      try failed()
      return
    }
    
    if match(token) {
      found(token)
    } else {
      notYet(meta)
      try lookAhead(match: match, found: found, notYet: notYet, failed: failed)
    }
  }
  
  // MARK: parse document  
  func parse(tokens: [TokenInfo]) throws -> OrgDocument {
    reset()
    self.tokens = Queue<TokenInfo>(data: tokens)
    return try parseDocument()
  }
  
  public func parse(lines: [String]) throws -> OrgDocument {
    let lexer = Lexer(lines: lines)
    return try parse(tokens: lexer.tokenize())
  }
  
  public func parse(content: String) throws -> OrgDocument {
    return try parse(lines: content.lines)
  }
  
}

typealias TokenCondition = (Token) -> Bool

// MARK: the real parsing logic
extension OrgParser {
  func parse(under container: NodeContainer,
             breaks: TokenCondition = { _ in return false },
             skips: TokenCondition = { _ in return false }) throws -> NodeContainer {
    guard let (_, token) = tokens.peek() else {
      return container
    }
    if breaks(token) { return container }
    if skips(token) {
      _ = tokens.dequeue()
      return try parse(under: container, breaks: breaks, skips: skips)
    }
    
    var newContainer = container
    var newContent: Node? = nil
    
    switch token {
    case .blank:
      _ = tokens.dequeue() // skip blank
      consumeAffiliatedKeywords()
      
    // blank means that existing affiliated keywords are not attached to anything
    case .setting:
      try dealWithAffiliatedKeyword()
    case let .headline(l, _):
      guard let index = container.index else {
        throw Errors.illegalNodeForContainer("\(type(of: container))")
      }
      if l <= index.indexes.count {
        return container // break the loop for finding higher level headline
      }
      var section = try parseSection()
      section.index = indexForNewSection(under: container)
      newContent = try parse(under: section, breaks: breaks, skips: skips)
    case .footnote:
      newContent = try parseFootnote()
    case .line:
      newContent = try parseParagraph()
    case let .comment(t):
      _ = tokens.dequeue()
      newContent = Comment(text: t)
    case .blockBegin:
      newContent = try parseBlock()
    case .drawerBegin:
      newContent = try parseDrawer()
    case .listItem:
      newContent = try parseList()
    case .planning(let keyword, let timestamp):
      _ = tokens.dequeue()
      newContent = Planning(keyword: keyword, timestamp: timestamp)
    case .tableRow, .horizontalSeparator:
      newContent = try parseTable()
    case .horizontalRule:
      _ = tokens.dequeue()
      newContent = HorizontalRule()
    default:
      throw Errors.unexpectedToken("\(token) is not expected")
    }
    if var c = newContent as? Affiliatable,
      let a = attrBuffer {
      c.attributes = a
      attrBuffer = nil
      newContainer.content.append(c as! Node)
    } else if let c = newContent {
      newContainer.content.append(c)
    }
    
    return try parse(under: newContainer)
  }
  
  fileprivate func indexForNewSection(under container: NodeContainer) -> OrgIndex {
    if let lastIndexed = container.content.filter({ $0.index != nil }).last {
      return (lastIndexed.index?.next)!
    }
    return (container.index?.in)!
  }
  
}
