//
//  SwiftOrgTests.swift
//  SwiftOrgTests
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import SwiftOrg


class TokenizerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        defineTokens()
    }

    func testTokenBlank() {
        evalBlank("", rawIsNil: true)
        evalBlank(" ")
        evalBlank("\t")
        evalBlank("  \t  ")
    }

    func testTokenSetting() {
        evalSetting("#+options: toc:nil", key: "options", value: "toc:nil")
        evalSetting("#+options:    toc:nil", key: "options", value: "toc:nil")
        evalSetting("#+TITLE: hello world", key: "TITLE", value: "hello world")
        evalSetting("#+TITLE: ", key: "TITLE", value: nil)
        evalSetting("#+TITLE:", key: "TITLE", value: nil)
    }

    func testTokenHeading() {
        evalHeadline("* Level One", stars: 1, text: "Level One")
        evalHeadline("** Level Two", stars: 2, text: "Level Two")
        evalHeadline("* TODO Level One with todo", stars: 1, text: "TODO Level One with todo")
        evalHeadline("* ", stars: 1, text: nil)
        evalLine("*", text: "*")
        evalListItem(" * ", indent: 1, text: nil, ordered: false)
    }

    func testTokenPlanning() {
        let date = "2017-01-09"
        let time = "18:00"
        let day = "Tue"

        let theDate = quickDate(date: date, time: time)

        evalPlanning("CLOSED: [\(date) \(day) \(time)]",
            keyword: "CLOSED",
            timestamp: Timestamp(active: false, date: theDate, repeater: nil))
        evalPlanning("SCHEDULED: <\(date) \(day) \(time) +2w>", // with repeater
            keyword: "SCHEDULED",
            timestamp: Timestamp(active: true, date: theDate, repeater: "+2w"))
        evalPlanning("SCHEDULED:   <\(date) \(day) \(time) +2w>", // with extra spaces before timestamp
            keyword: "SCHEDULED",
            timestamp: Timestamp(active: true, date: theDate, repeater: "+2w"))
        evalPlanning("   SCHEDULED: <\(date) \(day) \(time) +2w>", // with leading space
            keyword: "SCHEDULED",
            timestamp: Timestamp(active: true, date: theDate, repeater: "+2w"))
        evalPlanning("SCHEDULED: <\(date) \(day) \(time) +2w>     ", // with trailing space
            keyword: "SCHEDULED",
            timestamp: Timestamp(active: true, date: theDate, repeater: "+2w"))
        evalPlanning("    SCHEDULED: <\(date) \(day) \(time) +2w>     ", // with leading & trailing space
            keyword: "SCHEDULED",
            timestamp: Timestamp(active: true, date: theDate, repeater: "+2w"))

        // illegal ones are considered normal line
        evalLine("closed: <\(date) \(day) \(time)>", // case sensitive
            text: "closed: <\(date) \(day) \(time)>")

        evalLine("OPEN: <\(date) \(day) \(time)>", // illegal keyword
            text: "OPEN: <\(date) \(day) \(time)>")
    }

    func testTokenBlockBegin() {
        evalBlockBegin("#+begin_src java", type: "src", params: ["java"])
        evalBlockBegin("  #+begin_src", type: "src", params: nil)
        evalBlockBegin("  #+begin_src yaml exports: results :results value html",
                       type: "src",
                       params: ["yaml", "exports:", "results", ":results", "value", "html"])
    }

    func testTokenBlockEnd() {
        evalBlockEnd("#+END_SRC", type: "SRC")
        evalBlockEnd("  #+end_src", type: "src")
    }

    func testTokenComment() {
        evalComment("# a line of comment", text: "a line of comment")
        evalComment("#    a line of comment", text: "a line of comment")
        evalLine("#not comment", text: "#not comment")
    }

    func testTokenHorizontalRule() {
        evalHorizontalRule("-----")
        evalHorizontalRule("----------")
        evalHorizontalRule("  -----")
    }

    func testTokenListItem() {
        evalListItem("- list item", indent: 0, text: "list item", ordered: false)
        evalListItem(" + list item", indent: 1, text: "list item", ordered: false)
        evalListItem("  * list item", indent: 2, text: "list item", ordered: false)
        evalListItem("1. ordered list item", indent: 0, text: "ordered list item", ordered: true)
        evalListItem("  200) ordered list item", indent: 2, text: "ordered list item", ordered: true)
        // checkboxes
        evalListItem("- [ ] checkbox", indent: 0, text: "checkbox", ordered: false, checked: false)
        evalListItem("- [-] checkbox", indent: 0, text: "checkbox", ordered: false, checked: false)
        evalListItem("- [X] checkbox", indent: 0, text: "checkbox", ordered: false, checked: true)
        // illegal checkboxes
        evalListItem("- [] checkbox", indent: 0, text: "[] checkbox", ordered: false, checked: nil)
        evalListItem("- [X]checkbox", indent: 0, text: "[X]checkbox", ordered: false, checked: nil)
        evalListItem("- [Y] checkbox", indent: 0, text: "[Y] checkbox", ordered: false, checked: nil)
        evalLine("-[X] checkbox", text: "-[X] checkbox")
    }

    func testDrawer() {
        evalDrawerBegin(":PROPERTY:", name: "PROPERTY")
        evalDrawerBegin("  :properties:", name: "properties")
        evalDrawerBegin("  :properties:  ", name: "properties")
        evalDrawerEnd(":END:")
        evalDrawerEnd("  :end:")
        evalDrawerEnd("  :end:   ")
    }

    func testFootnote() {
        evalFootnote("[fn:1] the footnote", label: "1", content: "the footnote")
        evalFootnote("[fn:1]  \t the footnote", label: "1", content: "the footnote")
        evalFootnote("[fn:999] the footnote", label: "999", content: "the footnote")
        evalFootnote("[fn:23]", label: "23", content: nil)
        evalFootnote("[fn:23]  ", label: "23", content: nil)
        evalLine(" [fn:1] the footnote", text: "[fn:1] the footnote")
        evalLine("a[fn:1] the footnote", text: "a[fn:1] the footnote")
        evalLine("[fn:1]the footnote", text: "[fn:1]the footnote")
    }

    func testTable() {
        // valid table rows
        evalTableRow("| hello | world | y'all |", cells: ["hello", "world", "y'all"])
        evalTableRow("   | hello | world | y'all |", cells: ["hello", "world", "y'all"])
        evalTableRow("|     hello | world       |y'all |", cells: ["hello", "world", "y'all"])
        evalTableRow("| hello | world | y'all", cells: ["hello", "world", "y'all"])
        evalTableRow("|+", cells: ["+"])

        // invalid table rows
        evalLine(" hello | world | y'all |", text: "hello | world | y'all |")

        // horizontal separator
        evalHorizontalSeparator("|----+---+----|")
        evalHorizontalSeparator("|---=+---+----|")
        evalHorizontalSeparator("   |----+---+----|")
        evalHorizontalSeparator("|----+---+---")
        evalHorizontalSeparator("|-")
        evalHorizontalSeparator("|---")

        // invalud horizontal separator
        evalLine("----+---+----|", text: "----+---+----|")
    }
}
