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

  var text: String!
  var lines: [String]!
  override func setUp() {
    lines = [
      /* 00 */ "#+TITLE: Org Mode Syntax",
      /* 01 */ "#+TODO: TODO NEXT | DONE",
      /* 02 */ "",
      /* 03 */ "* TODO Section One         :tag1:tag2:",
      /* 04 */ "  DEADLINE: <2017-02-28 Tue>",
      /* 05 */ "  :PROPERTIES:",
      /* 06 */ "  :CATEGORY: nice",
      /* 07 */ "  :END:",
      /* 08 */ "",
      /* 09 */ "  Fist line of a paragraph.",
      /* 10 */ "  Second line of a paragraph.",
      /* 11 */ "-----",
      /* 12 */ "| Name         | Species    | Gender | Role         |",
      /* 13 */ "|--------------+------------+--------+--------------|",
      /* 14 */ "| Bruce Wayne  | Human      | M      | Batman       |",
      /* 15 */ "| Clark Kent   | Kryptonian | M      | Superman     |",
      /* 16 */ "| Diana Prince | Amazonian  | F      | Wonder Woman |",
      /* 17 */ "-----",
      /* 18 */ "- list item one",
      /* 19 */ "2. [ ] list item two",
      /* 20 */ "  1) [X] list item two.one",
      /* 21 */ "-----",
      /* 22 */ "#+BEGIN_SRC swift",
      /* 23 */ "print(\"org-mode is awesome.\")",
      /* 24 */ "#+END_SRC",
      /* 25 */ "-----",
      /* 26 */ "# This is a comment.",
      /* 27 */ "* [#A] Section Two",
      /* 28 */ "** Section Two.One",
      /* 29 */ "-----",
      /* 30 */ "[fn:1] footnote one.",
    ]

    text = lines.joined(separator: "\n")

  }

  func eval(_ mark: Mark?, name: String, value: String? = nil,
            file: StaticString = #file, line: UInt = #line,
            further: (Mark) -> Void = {_ in}) {
    guard let mark = mark else {
      XCTFail("mark is nil", file: file, line: line)
      return
    }
    evalMark(mark, on: text, name: name, value: value,
             file: file, line: line)
    further(mark)
  }

  func testMarking() throws {

    let marks = try mark(text)


    var cursor = 0
    eval(marks[cursor], name: "setting", value: "\(lines[0])\n") { mark in
      eval(mark[".key"], name: "setting.key", value: "TITLE")
      eval(mark[".value"], name: "setting.value", value: "Org Mode Syntax")
      cursor += 1
    }
    eval(marks[cursor], name: "setting", value: "\(lines[1])\n") { mark in
      eval(mark[".key"], name: "setting.key", value: "TODO")
      eval(mark[".value"], name: "setting.value", value: "TODO NEXT | DONE")
      cursor += 1
    }
    eval(marks[cursor], name: "blank", value: "\n")
    cursor += 1
    eval(marks[cursor], name: "headline", value: "\(lines[3])\n") { mark in
      eval(mark[".stars"], name: "headline.stars", value: "*")
      eval(mark[".keyword"], name: "headline.keyword", value: "TODO")
      eval(mark[".text"], name: "headline.text", value: "Section One")
      eval(mark[".tags"], name: "headline.tags", value: ":tag1:tag2:")
      cursor += 1
    }
    eval(marks[cursor], name: "planning", value: "\(lines[4])\n") { mark in
      eval(mark[".keyword"], name: "planning.keyword", value: "DEADLINE")
      eval(mark[".timestamp"], name: "planning.timestamp", value: "<2017-02-28 Tue>")
      cursor += 1
    }
    eval(marks[cursor], name: "drawer.begin", value: "\(lines[5])\n") { mark in
      eval(mark[".name"], name: "drawer.begin.name", value: "PROPERTIES")
      cursor += 1
    }
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
    eval(marks[cursor], name: "list.item", value: "\(lines[18])\n") { mark in
      eval(mark[".indent"], name: "list.item.indent", value: "")
      eval(mark[".bullet"], name: "list.item.bullet", value: "-")
      eval(mark[".text"], name: "list.item.text", value: "list item one")
      cursor += 1
    }
    eval(marks[cursor], name: "list.item", value: "\(lines[19])\n") { mark in
      eval(mark[".indent"], name: "list.item.indent", value: "")
      eval(mark[".bullet"], name: "list.item.bullet", value: "2.")
      eval(mark[".checker"], name: "list.item.checker", value: " ")
      eval(mark[".text"], name: "list.item.text", value: "list item two")
      cursor += 1
    }
    eval(marks[cursor], name: "list.item", value: "\(lines[20])\n") { mark in
      eval(mark[".indent"], name: "list.item.indent", value: "  ")
      eval(mark[".bullet"], name: "list.item.bullet", value: "1)")
      eval(mark[".checker"], name: "list.item.checker", value: "X")
      eval(mark[".text"], name: "list.item.text", value: "list item two.one")
      cursor += 1
    }

    eval(marks[cursor], name: "horizontalRule", value: "\(lines[21])\n")
    cursor += 1

    // block
    eval(marks[cursor], name: "block.begin", value: "\(lines[22])\n") { mark in
      eval(mark[".type"], name: "block.begin.type", value: "SRC")
      eval(mark[".params"], name: "block.begin.params", value: "swift")
      cursor += 1
    }
    eval(marks[cursor], name: "line", value: "\(lines[23])\n")
    cursor += 1
    eval(marks[cursor], name: "block.end", value: "\(lines[24])\n") { mark in
      eval(mark[".type"], name: "block.end.type", value: "SRC")
      cursor += 1
    }
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[25])\n")

    // comment
    cursor += 1
    eval(marks[cursor], name: "comment", value: "\(lines[26])\n")

    // section
    cursor += 1
    eval(marks[cursor], name: "headline", value: "\(lines[27])\n") { mark in
      eval(mark[".stars"], name: "headline.stars", value: "*")
      eval(mark[".priority"], name: "headline.priority", value: "A")
      eval(mark[".text"], name: "headline.text", value: "Section Two")
      cursor += 1
    }
    eval(marks[cursor], name: "headline", value: "\(lines[28])\n") { mark in
      eval(mark[".stars"], name: "headline.stars", value: "**")
      eval(mark[".text"], name: "headline.text", value: "Section Two.One")
      cursor += 1
    }
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[29])\n")
    cursor += 1

    // footnote
    eval(marks[cursor], name: "footnote", value: "\(lines[30])") { mark in
      eval(mark[".label"], name: "footnote.label", value: "1")
      eval(mark[".content"], name: "footnote.content", value: "footnote one.")
    }

  }

  func testStructualGrouping() throws {

    let marker = Marker()
    let marks = try marker.mark(text)

    var cursor = 0
    eval(marks[cursor], name: "setting", value: "\(lines[0])\n") { mark in
      eval(mark[".key"], name: "setting.key", value: "TITLE")
      eval(mark[".value"], name: "setting.value", value: "Org Mode Syntax")
      cursor += 1
    }
    eval(marks[cursor], name: "setting", value: "\(lines[1])\n") { mark in
      eval(mark[".key"], name: "setting.key", value: "TODO")
      eval(mark[".value"], name: "setting.value", value: "TODO NEXT | DONE")
      cursor += 1
    }
    eval(marks[cursor], name: "blank", value: "\n")
    cursor += 1
    eval(marks[cursor], name: "headline", value: "\(lines[3])\n") { mark in
      eval(mark[".stars"], name: "headline.stars", value: "*")
      eval(mark[".keyword"], name: "headline.keyword", value: "TODO")
      eval(mark[".text"], name: "headline.text", value: "Section One")
      eval(mark[".tags"], name: "headline.tags", value: ":tag1:tag2:")
      cursor += 1
    }
    eval(marks[cursor], name: "planning", value: "\(lines[4])\n") { mark in
      eval(mark[".keyword"], name: "planning.keyword", value: "DEADLINE")
      eval(mark[".timestamp"], name: "planning.timestamp", value: "<2017-02-28 Tue>")
      cursor += 1
    }
    eval(marks[cursor], name: "drawer") { mark in
      eval(mark[".begin"], name: "drawer.begin", value: "\(lines[5])\n") { mark in
        eval(mark[".name"], name: "drawer.begin.name", value: "PROPERTIES")
      }
      eval(mark[".content"], name: "drawer.content", value: "\(lines[6])\n")
      eval(mark[".end"], name: "drawer.end", value: "\(lines[7])\n")
      cursor += 1
    }
    eval(marks[cursor], name: "blank", value: "\n")
    cursor += 1
    eval(marks[cursor], name: "paragraph") { mark in
      eval(mark.marks[0], name: "paragraph.line", value: "\(lines[9])\n")
      eval(mark.marks[1], name: "paragraph.line", value: "\(lines[10])\n")
      cursor += 1
    }
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[11])\n")
    cursor += 1

    // table
    eval(marks[cursor], name: "table") { mark in
      eval(mark.marks[0], name: "table.row", value: "\(lines[12])\n")
      eval(mark.marks[1], name: "table.separator", value: "\(lines[13])\n")
      eval(mark.marks[2], name: "table.row", value: "\(lines[14])\n")
      eval(mark.marks[3], name: "table.row", value: "\(lines[15])\n")
      eval(mark.marks[4], name: "table.row", value: "\(lines[16])\n")
      cursor += 1
    }

    eval(marks[cursor], name: "horizontalRule", value: "\(lines[17])\n")
    cursor += 1

    // list
    eval(marks[cursor], name: "list") { mark in
      eval(mark.marks[0], name: "list.item", value: "\(lines[18])\n") { mark in
        eval(mark[".indent"], name: "list.item.indent", value: "")
        eval(mark[".bullet"], name: "list.item.bullet", value: "-")
        eval(mark[".text"], name: "list.item.text", value: "list item one")
      }
      eval(mark.marks[1], name: "list.item", value: "\(lines[19])\n") { mark in
        eval(mark[".indent"], name: "list.item.indent", value: "")
        eval(mark[".bullet"], name: "list.item.bullet", value: "2.")
        eval(mark[".checker"], name: "list.item.checker", value: " ")
        eval(mark[".text"], name: "list.item.text", value: "list item two")
      }
      eval(mark.marks[2], name: "list.item", value: "\(lines[20])\n") { mark in
        eval(mark[".indent"], name: "list.item.indent", value: "  ")
        eval(mark[".bullet"], name: "list.item.bullet", value: "1)")
        eval(mark[".checker"], name: "list.item.checker", value: "X")
        eval(mark[".text"], name: "list.item.text", value: "list item two.one")
      }
      cursor += 1
    }

    eval(marks[cursor], name: "horizontalRule", value: "\(lines[21])\n")
    cursor += 1

    // block
    eval(marks[cursor], name: "block") { mark in
      eval(mark.marks[0], name: "block.begin", value: "\(lines[22])\n") { mark in
        eval(mark[".type"], name: "block.begin.type", value: "SRC")
        eval(mark[".params"], name: "block.begin.params", value: "swift")
      }
      eval(mark.marks[1], name: "block.content", value: "\(lines[23])\n")
      eval(mark.marks[2], name: "block.end", value: "\(lines[24])\n") { mark in
        eval(mark[".type"], name: "block.end.type", value: "SRC")
      }
      cursor += 1
    }
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[25])\n")
    cursor += 1

    // comment
    eval(marks[cursor], name: "comment", value: "\(lines[26])\n")
    cursor += 1

    // section
    eval(marks[cursor], name: "headline", value: "\(lines[27])\n") { mark in
      eval(mark[".stars"], name: "headline.stars", value: "*")
      eval(mark[".priority"], name: "headline.priority", value: "A")
      eval(mark[".text"], name: "headline.text", value: "Section Two")
      cursor += 1
    }
    eval(marks[cursor], name: "headline", value: "\(lines[28])\n") { mark in
      eval(mark[".stars"], name: "headline.stars", value: "**")
      eval(mark[".text"], name: "headline.text", value: "Section Two.One")
      cursor += 1
    }
    eval(marks[cursor], name: "horizontalRule", value: "\(lines[29])\n")
    cursor += 1

    // footnote
    eval(marks[cursor], name: "footnote", value: "\(lines[30])") { mark in
      eval(mark[".label"], name: "footnote.label", value: "1")
      eval(mark[".content"], name: "footnote.content", value: "footnote one.")
    }

  }

  func testSection() throws {
    let marker = Marker()
    let marks = try marker.mark(text, sectionize: true)

    for section in marks.filter({ $0.name == "section" }) {
      print(">>>>>>>>>>>>>>>>>>>>>")
      print("\(section.value(on: text))")
      print("<<<<<<<<<<<<<<<<<<<<<")
    }
  }
}
