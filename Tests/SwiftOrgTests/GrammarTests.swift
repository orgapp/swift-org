//
//  LexerTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 8/12/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import SwiftOrg

class GrammarTests: XCTestCase {
  
  func testGrammar() throws {
    
    let lines = [
      "#+TITLE: Org Mode Syntax",  // 0
      "#+TODO: TODO NEXT | DONE", // 1
      "", // 2
      "* TODO Section One         :tag1:tag2:", // 3
      "  DEADLINE: <2017-02-28 Tue>", // 4
      "  :PROPERTIES:", // 5
      "  :CATEGORY: nice", // 6
      "  :END:", // 7
      "", // 8
      "  Fist line of a paragraph.", // 9
      "  Second line of a paragraph.", // 10
      "-----", // 11
      "| Name         | Species    | Gender | Role         |", // 12
      "|--------------+------------+--------+--------------|", // 13
      "| Bruce Wayne  | Human      | M      | Batman       |", // 14
      "| Clark Kent   | Kryptonian | M      | Superman     |", // 15
      "| Diana Prince | Amazonian  | F      | Wonder Woman |", // 16
      "-----", // 17
      "- list item one", // 18
      "2. [ ] list item two", // 19
      "  1) [X] list item two.one", // 20
      "-----", // 21
      "#+BEGIN_SRC swift", // 22
      "print(\"org-mode is awesome.\")", // 23
      "#+END_SRC", // 24
      "-----", // 25
      "# This is a comment.", // 26
      "* [#A] Section Two", // 27
      "** Section Two.One", // 28
      "-----", // 29
      "[fn:1] footnote one.", // 30
      ]
    
    let text = lines.joined(separator: "\n")
    

    let marks = try mark(text: text)
    
    func eval(_ mark: Mark, name: String, value: String,
              file: StaticString = #file, line: UInt = #line) {
      evalMark(mark, on: text, name: name, value: value,
               file: file, line: line)
    }
    
    var cursor = 0
    eval(marks[cursor], name: "setting", value: "\(lines[0])\n")
    eval(marks[cursor].marks[0], name: "setting.key", value: "TITLE")
    eval(marks[cursor].marks[1], name: "setting.value", value: "Org Mode Syntax")
    cursor += 1
    eval(marks[cursor], name: "setting", value: "\(lines[1])\n")
    eval(marks[cursor].marks[0], name: "setting.key", value: "TODO")
    eval(marks[cursor].marks[1], name: "setting.value", value: "TODO NEXT | DONE")
    cursor += 1
    eval(marks[cursor], name: "blank", value: "\n")
    cursor += 1
    eval(marks[cursor], name: "headline", value: "\(lines[3])\n")
    eval(marks[cursor].marks[0], name: "headline.stars", value: "*")
    eval(marks[cursor].marks[1], name: "headline.keyword", value: "TODO")
    eval(marks[cursor].marks[2], name: "headline.text", value: "Section One")
    eval(marks[cursor].marks[3], name: "headline.tags", value: ":tag1:tag2:")
    cursor += 1
    eval(marks[cursor], name: "planning", value: "\(lines[4])\n")
    eval(marks[cursor].marks[0], name: "planning.keyword", value: "DEADLINE")
    eval(marks[cursor].marks[1], name: "planning.timestamp", value: "<2017-02-28 Tue>")
    cursor += 1
    eval(marks[cursor], name: "drawer.begin", value: "\(lines[5])\n")
    eval(marks[cursor].marks[0], name: "drawer.begin.name", value: "PROPERTIES")
    cursor += 1
    eval(marks[cursor], name: "line", value: "\(lines[6])\n")
    cursor += 1
    eval(marks[cursor], name: "drawer.end", value: "\(lines[7])\n")
    cursor += 1
    eval(marks[cursor], name: "blank", value: "\n")
    cursor += 1
    eval(marks[cursor], name: "line", value: "\(lines[9])\n")
    cursor += 1
    eval(marks[cursor], name: "line", value: "\(lines[10])\n")
    cursor += 1
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[11])\n")
    
    // table
    cursor += 1
    eval(marks[cursor], name: "table.row", value: "\(lines[12])\n")
    cursor += 1
    eval(marks[cursor], name: "table.separator", value: "\(lines[13])\n")
    cursor += 1
    eval(marks[cursor], name: "table.row", value: "\(lines[14])\n")
    cursor += 1
    eval(marks[cursor], name: "table.row", value: "\(lines[15])\n")
    cursor += 1
    eval(marks[cursor], name: "table.row", value: "\(lines[16])\n")
    
    cursor += 1
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[17])\n")

    // list
    cursor += 1
    eval(marks[cursor], name: "list.item", value: "\(lines[18])\n")
    eval(marks[cursor].marks[0], name: "list.item.indent", value: "")
    eval(marks[cursor].marks[1], name: "list.item.bullet", value: "-")
    eval(marks[cursor].marks[2], name: "list.item.text", value: "list item one")
    cursor += 1
    eval(marks[cursor], name: "list.item", value: "\(lines[19])\n")
    eval(marks[cursor].marks[0], name: "list.item.indent", value: "")
    eval(marks[cursor].marks[1], name: "list.item.bullet", value: "2.")
    eval(marks[cursor].marks[2], name: "list.item.checker", value: " ")
    eval(marks[cursor].marks[3], name: "list.item.text", value: "list item two")
    cursor += 1
    eval(marks[cursor], name: "list.item", value: "\(lines[20])\n")
    eval(marks[cursor].marks[0], name: "list.item.indent", value: "  ")
    eval(marks[cursor].marks[1], name: "list.item.bullet", value: "1)")
    eval(marks[cursor].marks[2], name: "list.item.checker", value: "X")
    eval(marks[cursor].marks[3], name: "list.item.text", value: "list item two.one")
    
    cursor += 1
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[21])\n")

    // block
    cursor += 1
    eval(marks[cursor], name: "block.begin", value: "\(lines[22])\n")
    eval(marks[cursor].marks[0], name: "block.begin.type", value: "SRC")
    eval(marks[cursor].marks[1], name: "block.begin.params", value: "swift")
    cursor += 1
    eval(marks[cursor], name: "line", value: "\(lines[23])\n")
    cursor += 1
    eval(marks[cursor], name: "block.end", value: "\(lines[24])\n")
    eval(marks[cursor].marks[0], name: "block.end.type", value: "SRC")
    
    cursor += 1
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[25])\n")
    
    // comment
    cursor += 1
    eval(marks[cursor], name: "comment", value: "\(lines[26])\n")
    
    // section
    cursor += 1
    eval(marks[cursor], name: "headline", value: "\(lines[27])\n")
    eval(marks[cursor].marks[0], name: "headline.stars", value: "*")
    eval(marks[cursor].marks[1], name: "headline.priority", value: "A")
    eval(marks[cursor].marks[2], name: "headline.text", value: "Section Two")
    
    cursor += 1
    eval(marks[cursor], name: "headline", value: "\(lines[28])\n")
    eval(marks[cursor].marks[0], name: "headline.stars", value: "**")
    eval(marks[cursor].marks[1], name: "headline.text", value: "Section Two.One")
  
    cursor += 1
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[29])\n")
    
    // footnote
    cursor += 1
    eval(marks[cursor], name: "footnote", value: "\(lines[30])")
    eval(marks[cursor].marks[0], name: "footnote.label", value: "1")
    eval(marks[cursor].marks[1], name: "footnote.content", value: "footnote one.")
  }
}
