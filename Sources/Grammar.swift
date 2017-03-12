//
//  Grammar.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 11/03/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

fileprivate let space = "[ \\t]"
fileprivate let newline = "\\n"
fileprivate let eol = "(\(newline)|\\Z)" // end of line

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

struct Keywords {
  static var todo = ["TODO", "DONE"]
  
  static var priority = "ABC"
  
  static var planning = ["DEADLINE", "SCHEDULED", "CLOSED"]
}

struct Grammar {
  var patterns: [Pattern]
  
  
  fileprivate static var todosPattern: String {
    get {
      return "(?:(\(Keywords.todo.joined(separator: "|")))\(space)+)"
    }
  }
  
  fileprivate static var priorityPattern: String {
    get {
      return "(?:\\[#([\(Keywords.priority)])\\]\\s+)"
    }
  }
  
  fileprivate static var tagsPattern: String {
    get {
      return "(?:\(space)+((?:\\:.+)+\\:)\(space)*)"
    }
  }
  
  fileprivate static var planningKeywordPattern: String {
    get {
      return "(\(Keywords.planning.joined(separator: "|")))"
    }
  }
  
  static let main = Grammar(patterns: [
    Pattern("blank", match: "^\(space)*\(eol)"),
    
    Pattern("setting", match: "^#\\+([a-zA-Z_]+):\(space)*([^\\n]*)\(eol)",
      captures: [ 1: "setting.key", 2: "setting.value" ]),
    
    Pattern("headline", match: "^(\\*+)\(space)\(todosPattern)?\(priorityPattern)?(.*?)\(tagsPattern)?\(eol)",
      captures: [
        1: "headline.stars",
        2: "headline.keyword",
        3: "headline.priority",
        4: "headline.text",
        5: "headline.tags" ]),
    
    Pattern("planning", match: "^\(space)*\(planningKeywordPattern):\(space)+(.+)\(eol)",
      captures: [1: "planning.keyword", 2: "planning.timestamp"]),
    
    Pattern("block.begin", match: "^\(space)*#\\+begin_([a-z]+)(?:\(space)+([^\\n]*))?\(eol)",
      options: [.caseInsensitive],
      captures: [ 1: "block.begin.type", 2: "block.begin.params" ]),
    
    Pattern("block.end", match: "^\(space)*#\\+end_([a-z]+)\(eol)",
      options: [.caseInsensitive],
      captures: [ 1: "block.end.type" ]),
    
    Pattern("drawer.end", match: "^\(space)*:(end|END):\(space)*\(eol)"),
    Pattern("drawer.begin", match: "^\(space)*:([a-zA-Z]+):\(space)*\(eol)",
      captures: [ 1: "drawer.name" ]),
    
    
    Pattern("horizontalRule", match: "^\(space)*-{5,}\(eol)"),
    
    Pattern("comment", match: "^\(space)*#\(space)+(.*)\(eol)"),
    
    Pattern("list.item", match: "^(\(space)*)([-+*]|\\d+(?:\\.|\\)))\(space)+(?:\\[([ X-])\\]\(space)+)?(.*)\(eol)",
      captures: [ 1: "list.item.indent", 2: "list.item.bullet", 3: "list.item.checker", 4: "list.item.text" ]),
    
    Pattern("footnote", match: "^\\[fn:(\\d+)\\](?:\(space)+(.*))?\(eol)",
      captures: [1: "footnote.label", 2: "footnote.content"]),
    
    Pattern("table.separator", match: "^\(space)*\\|-.*\(eol)"),
    Pattern("table.row", match: "^\(space)*\\|(?:[^\\r\\n\\|]*\\|?)+\(eol)"),
    
    Pattern("line", match: "^[^\\n]+\(eol)"),
    ])
  
  static let blockContent = Grammar(patterns: [
    Pattern("block.content", match: ".*")
    ])
}

public struct Mark {
  let range: Range<String.Index>
  let name: String
  
}

extension String {
  func nsRange(from range: Range<String.Index>) -> NSRange {
    let from = range.lowerBound.samePosition(in: utf16)
    let to = range.upperBound.samePosition(in: utf16)
    return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                   length: utf16.distance(from: from, to: to))
  }
}

extension String {
  func range(from nsRange: NSRange) -> Range<String.Index>? {
    guard
      let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
      let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
      let from = from16.samePosition(in: self),
      let to = to16.samePosition(in: self)
      else { return nil }
    return from ..< to
  }
}

typealias Callback = (_ scope: String, _ range: Range<String.Index>) -> Void

fileprivate func parse(text: String, callback: Callback) throws {
  var range = text.startIndex..<text.endIndex
  while !range.isEmpty {
    range = try _parse(text: text, range: range, callback: callback)
  }
}

fileprivate func _parse(text: String, range: Range<String.Index>, callback: Callback) throws -> Range<String.Index> {
  if range.isEmpty { return range }
  for pattern in Grammar.main.patterns {
    guard let m = pattern.match.expression.firstMatch(
      in: text, options: [], range: text.nsRange(from: range)) else { continue }
    
    let matchRange = text.range(from: m.range)!
    callback(pattern.name, matchRange)
    if let captures = pattern.match.captures?
      .sorted(by: { $0.key < $1.key }) {
      
      for (index, name) in captures {
        if let r = text.range(from:m.rangeAt(index)) {
          callback(name, r)
        }
      }
    }
    
    return matchRange.upperBound..<range.upperBound
  }
  
  throw Errors.cannotFindToken("Nothing Matches")
}

public func mark(text: String) throws -> [Mark] {
  var marks = [Mark]()
  try parse(text: text) { name, range in
    marks.append(Mark(range: range, name: name))
  }
  return marks
}
