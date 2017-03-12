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
      "- list item tow", // 19
      "  - list item tow.one", // 20
      "-----", // 21
      "#+BEGIN_SRC swift", // 22
      "print(\"org-mode is awesome.\")", // 23
      "#+END_SRC", // 24
      "-----", // 25
      "# This is a comment.", // 26
      "* [#A] Section Two", // 27
      "** Section Two.One", // 28
      ]
    
    let text = lines.joined(separator: "\n")
    

    let marks = try mark(text: text)
    var cursor = 0
    
    func eval(name: String, value: String,
              file: StaticString = #file, line: UInt = #line) {
      evalMark(marks[cursor], on: text, name: name, value: value,
           file: file, line: line)
      cursor += 1
    }

    eval(name: "setting", value: "\(lines[0])\n")
    eval(name: "setting.value", value: "Org Mode Syntax")
    eval(name: "setting.key", value: "TITLE")
    eval(name: "setting", value: "\(lines[1])\n")
    eval(name: "setting.value", value: "TODO NEXT | DONE")
    eval(name: "setting.key", value: "TODO")
    eval(name: "blank", value: "\n")
    eval(name: "headline", value: "\(lines[3])\n")
    eval(name: "headline.tags", value: ":tag1:tag2:")
    eval(name: "headline.keyword", value: "TODO")
    eval(name: "headline.stars", value: "*")
    eval(name: "headline.text", value: "Section One")
    eval(name: "planning", value: "\(lines[4])\n")
    eval(name: "planning.timestamp", value: "<2017-02-28 Tue>")
    eval(name: "planning.keyword", value: "DEADLINE")
    eval(name: "drawer.begin", value: "\(lines[5])\n")
    eval(name: "drawer.name", value: "PROPERTIES")
    eval(name: "line", value: "\(lines[6])\n")
    eval(name: "drawer.end", value: "\(lines[7])\n")
    eval(name: "blank", value: "\n")
    eval(name: "line", value: "\(lines[9])\n")
    eval(name: "line", value: "\(lines[10])\n")
    eval(name: "horizontalRule", value: "\(lines[11])\n")
    
    // table
    eval(name: "table.row", value: "\(lines[12])\n")
    eval(name: "table.seperator", value: "\(lines[13])\n")
    eval(name: "table.row", value: "\(lines[14])\n")
    eval(name: "table.row", value: "\(lines[15])\n")
    eval(name: "table.row", value: "\(lines[16])\n")
    eval(name: "horizontalRule", value: "\(lines[17])\n")
    
    // list
    eval(name: "list.item", value: "\(lines[18])\n")
    eval(name: "list.item", value: "\(lines[19])\n")
    eval(name: "list.item", value: "\(lines[20])\n")
    eval(name: "horizontalRule", value: "\(lines[21])\n")
    
    // block
    eval(name: "block.begin", value: "\(lines[22])\n")
    eval(name: "block.begin.params", value: "swift")
    eval(name: "block.begin.type", value: "SRC")
    eval(name: "line", value: "\(lines[23])\n")
    eval(name: "block.end", value: "\(lines[24])\n")
    eval(name: "block.end.type", value: "SRC")
    eval(name: "horizontalRule", value: "\(lines[25])\n")
    
    // comment
    eval(name: "comment", value: "\(lines[26])\n")
    
    // section
    eval(name: "headline", value: "\(lines[27])\n")
    eval(name: "headline.priority", value: "A")
    eval(name: "headline.stars", value: "*")
    eval(name: "headline.text", value: "Section Two")
    
    eval(name: "headline", value: "\(lines[28])")
    eval(name: "headline.stars", value: "**")
    eval(name: "headline.text", value: "Section Two.One")
  
  }
}
