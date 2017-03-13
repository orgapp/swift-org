//
//  Parser.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 13/03/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

typealias Callback = (_ name: String, _ range: Range<String.Index>) -> Void

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

public func mark(text: String, folded: Bool = true) throws -> [Mark] {
  var marks = [Mark]()
  try parse(text: text) { name, range in
    let mark = Mark(range: range, name: name)
    if folded,
      let last = marks.last,
      name.scope(under: last.name) {
      marks[marks.endIndex - 1].include(mark)
    } else {
      marks.append(mark)
    }
  }
  return marks
}

fileprivate func matchMaking(_ marks: [Mark],
                             name: String,
                             matchBegin: (Mark) -> Bool,
                             matchEnd: (Mark) -> Bool,
                             markContent: (Range<String.Index>) -> [Mark],
                             beginFallback: (Mark) -> Mark) -> [Mark] {
  var marks = marks
  guard let beginIndex = marks.index(where: matchBegin) else {
    return marks
  }
  
  let begin = marks[beginIndex]
  
  guard let endIndex = marks[beginIndex+1..<marks.endIndex].index(where: matchEnd) else {
    marks[beginIndex] = beginFallback(marks[beginIndex])
    return matchMaking(marks, name: name, matchBegin: matchBegin, matchEnd: matchEnd, markContent: markContent, beginFallback: beginFallback)
  }
  let end = marks[endIndex]
  
  let contentRange = begin.range.upperBound..<end.range.lowerBound
  var contentMarks = [begin]
  contentMarks.append(contentsOf: markContent(contentRange))
  contentMarks.append(end)
  marks.removeSubrange(beginIndex..<endIndex+1)
  var container = Mark(range: begin.range.lowerBound..<end.range.upperBound, name: name)
  container.marks = contentMarks
  marks.insert(container, at: beginIndex)
  return matchMaking(marks, name: name, matchBegin: matchBegin, matchEnd: matchEnd, markContent: markContent, beginFallback: beginFallback)
}

fileprivate func group(_ marks: [Mark],
                       name: String,
                       renameTo: String? = nil,
                       match: (Mark) -> Bool) -> [Mark] {
  guard let firstIndex = marks.index(where: match) else {
    return marks
  }
  var marks = marks
  var theGroup = [marks[firstIndex]]
  var cursor = firstIndex + 1
  while cursor < marks.count && match(marks[cursor]) {
    theGroup.append(marks[cursor])
    cursor += 1
  }
  marks.removeSubrange(firstIndex..<cursor)
  var grouped = Mark(name, marks: theGroup)!
  if let newName = renameTo {
    theGroup = theGroup.map { mark in
      var m = mark
      m.name = newName
      return m
    }
  }
  grouped.marks = theGroup
  marks.insert(grouped, at: firstIndex)
  return marks
}

public func analyze(_ text: String, marks: [Mark]) throws -> [Mark] {
  // match block
  var blockType = ""
  var marks = matchMaking(
    marks, name: "block",
    matchBegin: { mark in
      if mark.name == "block.begin" {
        blockType = mark[".type"]!.value(on: text)
        return true
      }
      return false
  }, matchEnd: { mark in
    return mark.name == "block.end" &&
      mark[".type"]?.value(on: text) == blockType
  }, markContent: { range in
    return [Mark(range: range, name: "block.content")]
  }, beginFallback: { mark in
    return mark
  })
  
  // match drawer
  marks = matchMaking(
    marks, name: "drawer",
    matchBegin: { mark in
      return mark.name == "drawer.begin"
  }, matchEnd: { mark in
    return mark.name == "drawer.end"
  }, markContent: { range in
    return [Mark(range: range, name: "drawer.content")]
  }, beginFallback: { mark in
    var mark = mark
    mark.name = "line"
    return mark
  })
  
  // match paragraph
  marks = group(marks, name: "paragraph", renameTo: "paragraph.line") { $0.name == "line" }
  marks = group(marks, name: "list") { $0.name == "list.item" }
  marks = group(marks, name: "table") { $0.name.hasPrefix("table.") }
  
  return marks
}
