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
      captures: [ 1: "drawer.begin.name" ]),
    
    
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
