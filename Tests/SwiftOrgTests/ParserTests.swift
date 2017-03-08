//
//  ParserTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/02/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

fileprivate func eval(_ node: Node?, makesure: (Section) -> Void) {
  guard let section = node as? Section else {
    XCTFail("Section is expected")
    return
  }
  makesure(section)
}

class ParserTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  // MARK: Affiliated Keywords
  func testParseSettings() {
    guard let doc = parse([
      "#+options: toc:nil",
      "#+TITLE: ",
      "  ",
      "* First Head Line",
      ]) else { return }
    XCTAssertEqual(doc.settings.count, 1)
    XCTAssertEqual(doc.settings["options"], "toc:nil")
    XCTAssertNil(doc.settings["TITLE"])
  }
  
  func testDefaultTodos() {
    let parser = OrgParser(defaultTodos: [["TODO", "NEXT"], ["DONE", "CANCELED"]])
    let content = ["Use Default TODOs"]
    guard let docWithDefaultParser = parse(content) else { return }
    guard let docWithModifiedParser = parse(content, with: parser) else { return }
    
    XCTAssertEqual(2, docWithDefaultParser.todos.count)
    XCTAssertEqual(["TODO"], docWithDefaultParser.todos[0])
    XCTAssertEqual(["DONE"], docWithDefaultParser.todos[1])
    XCTAssertEqual(2, docWithModifiedParser.todos.count)
    XCTAssertEqual(["TODO", "NEXT"], docWithModifiedParser.todos[0])
    XCTAssertEqual(["DONE", "CANCELED"], docWithModifiedParser.todos[1])
  }
  
  func testInBufferTodos() {
    guard let doc = parse([
      "#+TODO: HELLO WORLD | ORG MODE",
      ]) else { return }
    XCTAssertEqual(2, doc.todos.count)
    XCTAssertEqual(["HELLO", "WORLD"], doc.todos[0])
    XCTAssertEqual(["ORG", "MODE"], doc.todos[1])
  }
  
  func testAffiliatedKeywordsOnItemsOtherThanDocument() {
    guard let doc = parse([
      "#+NAME: my headline",
      "* First Head Line",
      "",
      "#+NAME: my headline2",
      "",
      "* Second Head Line",
      "",
      "#+NAME: my code block",
      "#+begin_src",
      "#+end_src",
      ]) else { return }
    XCTAssertEqual(2, doc.content.count)
    eval(doc.content[0]) {sec in
      XCTAssertEqual(1, sec.attributes.count)
      XCTAssertEqual("my headline", sec.attributes["NAME"])
    }
    eval(doc.content[1]) {sec in
      XCTAssertEqual(0, sec.attributes.count)
      XCTAssertEqual(1, sec.content.count)
      guard let cb = sec.content[0] as? Block else {
        XCTFail("Should be code block")
        return
      }
      XCTAssertEqual(1, cb.attributes.count)
      XCTAssertEqual("my code block", cb.attributes["NAME"])
    }
  }
  
  // MARK: Heading
  
  func testParseHeadline() {
    guard let doc = parse([
      "#+TODO: NEXT TODO",
      "* Header 1",
      "* TODO Header 2",
      "  A line of content.",
      "** Header 2.1",
      "*** Header 2.1.1",
      "** Header 2.2",
      "* NEXT Customized todo",
      "* "
      ]) else { return }
    XCTAssertEqual(doc.content.count, 4)
    
    eval(doc.content[0]) { sec in
      XCTAssertEqual(sec.stars, 1)
      XCTAssertEqual(sec.title, "Header 1")
      XCTAssertEqual(sec.content.count, 0)
    }
    
    eval(doc.content[1]) { sec in
      XCTAssertEqual(sec.stars, 1)
      XCTAssertEqual(sec.title, "Header 2")
      XCTAssertEqual(sec.keyword, "TODO")
      XCTAssertEqual(sec.content.count, 3)
      guard let line = sec.content[0] as? Paragraph else {
        XCTFail("Expect h2.nodes[0] to be Line")
        return
      }
      XCTAssertEqual(line.text, "A line of content.")
    }
    
    eval(doc.content[2]) { sec in
      XCTAssertEqual(sec.title, "Customized todo")
      XCTAssertEqual(sec.keyword, "NEXT")
    }
    
    eval(doc.content[3]) { sec in
      XCTAssertNil(sec.title)
      XCTAssertNil(sec.keyword)
    }
  }
  
  func testParseDrawer() {
    let lines = [
      "* the headline",
      "  :LOGBOOK:",
      "  - hello world",
      "  - hello world again",
      "  :END:",
      "  :PROPERTIES:",
      "  - property 1",
      "  - property 2",
      "  :END:",
      ]
    let doc = parse(lines)
    
    eval(doc?.content[0]) { section in
      XCTAssertNotNil(section.drawers)
      XCTAssertEqual(section.drawers?.count, 2)
      XCTAssertEqual(section.drawers?[0].name, "LOGBOOK")
      XCTAssertEqual(section.drawers?[1].name, "PROPERTIES")
    }
  }
  
  func testMalfunctionDrawer() {
    let lines = [
      "* the headline",
      "",
      "  :LOGBOOK:",
      "  hello world",
      "  hello world again",
      "  :END:",
      ]
    let doc = parse(lines)
    
    eval(doc?.content[0]) { section in
      XCTAssertEqual(1, section.drawers?.count)
    }
    //        XCTAssertEqual(section.content.count, 2)
  }
  
  func testPriority() {
    guard let doc = parse([
      "* TODO [#A] top priority task",
      "* [#A] top priority item",
      "* [#D] no priority item",
      "* DONE [#a] top priority item",
      "* BREAKING [#A] no priority item",
      ]) else { XCTFail("failed to parse lines."); return }
    eval(doc.content[0]) { sec in
      XCTAssertEqual(sec.priority, .A)
      XCTAssertEqual(sec.keyword, "TODO")
      XCTAssertEqual(sec.title, "top priority task")
    }
    
    eval(doc.content[1]) { sec in
      XCTAssertEqual(sec.priority, .A)
      XCTAssertEqual(sec.keyword, nil)
      XCTAssertEqual(sec.title, "top priority item")
    }
    
    eval(doc.content[2]) { sec in
      XCTAssertEqual(sec.priority, nil)
      XCTAssertEqual(sec.keyword, nil)
      XCTAssertEqual(sec.title, "[#D] no priority item")
    }
    
    eval(doc.content[3]) { sec in
      XCTAssertEqual(sec.priority, .A)
      XCTAssertEqual(sec.keyword, "DONE")
      XCTAssertEqual(sec.title, "top priority item")
    }
    
    eval(doc.content[4]) { sec in
      XCTAssertEqual(sec.priority, nil)
      XCTAssertEqual(sec.keyword, nil)
      XCTAssertEqual(sec.title, "BREAKING [#A] no priority item")
    }
  }
  
  func testTags() {
    guard let doc = parse([
      "* line with one tag.   :tag1:",
      "* line with multiple tags.   :tag1:tag2:tag3:",
      "* line with trailing spaces.   :tag1:tag2:tag3:  ",
      ]) else { XCTFail("failed to parse lines."); return }
    
    eval(doc.content[0]) { sec in
      XCTAssertNotNil(sec.tags)
      XCTAssertEqual(sec.tags!, ["tag1"])
    }
    eval(doc.content[1]) { sec in
      XCTAssertEqual(sec.tags!, ["tag1", "tag2", "tag3"])
    }
    
    eval(doc.content[2]) { sec in
      XCTAssertEqual(sec.tags!, ["tag1", "tag2", "tag3"])
    }
  }
  
  func testPlanning() {
    let keyword = "CLOSED"
    let date = "2017-01-09"
    let day = "Tue"
    let time = "18:00"
    guard let doc = parse([
      "* line with planning",
      "  \(keyword): [\(date) \(day) \(time)]",
      "* line without planning",
      ]) else { XCTFail("failed to parse lines."); return }
    
    eval(doc.content[0]) { sec in
      XCTAssertNotNil(sec.planning)
      guard let planning = sec.planning else {
        XCTFail("Failed to parse planning")
        return
      }
      XCTAssertEqual(planning.keyword.rawValue, keyword)
      XCTAssertFalse(planning.timestamp!.active)
      XCTAssertEqual(planning.timestamp?.date, quickDate(date: date, time: time))
    }
    
    eval(doc.content[1]) { sec in
      XCTAssertNil(sec.planning)
    }
  }
  
  // MARK: Block
  
  func testParseBlock() {
    guard let doc = parse([
      "#+begin_src java",
      "  class HelloWorld {",
      "  # print(\"Hell World\");",
      "  }",
      "#+END_SRC",
      "  #+begin_src",
      "  #+end_src",
      "  #+begin_src yaml exports: results :results value html",
      "#+END_SRC",
      "# +begin_src java",
      "#+begin_src no-end",
      " This is a normal line",
      " # print(\"Hell World\");",
      ]) else { return }
    
    XCTAssertEqual(doc.content.count, 6)
    guard let block1 = doc.content[0] as? Block else {
      XCTFail("Expect 0 to be Block")
      return
    }
    XCTAssertEqual(block1.name, "src")
    XCTAssertEqual(block1.params!, ["java"])
    XCTAssertEqual(block1.content, ["  class HelloWorld {", "  # print(\"Hell World\");", "  }"])
    guard let block2 = doc.content[1] as? Block else {
      XCTFail("Expect 1 to be Block")
      return
    }
    XCTAssertEqual(block2.name, "src")
    XCTAssertNil(block2.params)
    guard let block3 = doc.content[2] as? Block else {
      XCTFail("Expect 2 to be Block")
      return
    }
    XCTAssertEqual(block3.name, "src")
    XCTAssertEqual(block3.params!, ["yaml", "exports:", "results",  ":results",  "value", "html"])
    guard let comment = doc.content[3] as? Comment else {
      XCTFail("Expect 3 to be Comment")
      return
    }
    XCTAssertEqual(comment.text, "+begin_src java")
    
    // TODO make these assertion work
    //                expect(doc.children[4].value).to(beAnInstanceOf(Paragraph))
    //                expect(doc.children[5].value).to(beAnInstanceOf(Comment))
  }
  
  // MARK: List
  func testParseList() {
    let lines = [
      "- list item",
      " 1. sub list item",
      " 1.  sub list item",
      "- list item",
      ]
    let doc = parse(lines)
    guard let list = doc?.content[0] as? List else {
      XCTFail("Expect 0 to be List")
      return
    }
    XCTAssertEqual(list.items.count, 2)
    XCTAssertFalse(list.ordered)
    XCTAssertEqual(list.items[0].text, "list item")
    XCTAssertEqual(list.items[1].text, "list item")
    XCTAssertNil(list.items[1].subList)
    
    guard let subList = list.items[0].subList else {
      XCTFail("Expecting sublist")
      return
    }
    XCTAssertEqual(subList.items.count, 2)
    XCTAssertTrue(subList.ordered)
    XCTAssertEqual(subList.items[0].text, "sub list item")
    XCTAssertEqual(subList.items[1].text, "sub list item")
  }
  
  func testListItemWithCheckbox() {
    let lines = [
      // legal checkboxes
      "- [ ] list item",
      "- [X] list item",
      "1. [-] list item",
      // illegal checkboxes
      "- [] list item",
      "- [Y] list item",
      ]
    let doc = parse(lines)
    guard let list = doc?.content[0] as? List else {
      XCTFail("Expect 0 to be List")
      return
    }
    XCTAssertEqual(list.items.count, 5)
    XCTAssertFalse(list.ordered)
    XCTAssertEqual(list.items[0].text, "list item")
    XCTAssertEqual(list.progress, Progress(1, outof: 3))
  }
  
  // MARK: Paragraph
  
  func testParseParagraph() {
    let lines = [
      "Line one.",
      "Line two.",
      "Line three.",
      "",
      "Line four.",
      "Line five.",
      ]
    let doc = parse(lines)
    guard let para1 = doc?.content[0] as? Paragraph else {
      XCTFail("Expect 0 to be Paragraph")
      return
    }
    XCTAssertEqual(para1.lines.count, 3)
    XCTAssertEqual(para1.lines, ["Line one.", "Line two.", "Line three."])
    
    guard let para2 = doc?.content[1] as? Paragraph else {
      XCTFail("Expect 0 to be Paragraph")
      return
    }
    XCTAssertEqual(para2.lines.count, 2)
    XCTAssertEqual(para2.lines, ["Line four.", "Line five."])
  }
  
  
  // MARK: Table
  func testParseTable() {
    guard let doc = parse([
      "| Name         | Species    | Gender | Role         |",
      "|--------------+------------+--------+--------------|",
      "| Bruce Wayne  | Human      | M      | Batman       |",
      "| Clark Kent   | Kryptonian | M      | Superman     |",
      "| Diana Prince | Amazonian  | F      | Wonder Woman |",
      ]) else { return }
    
    XCTAssertEqual(doc.content.count, 1)
    guard let table = doc.content[0] as? Table else {
      XCTFail("Expect 0 to be Table")
      return
    }
    XCTAssertEqual(table.rows.count, 4)
    XCTAssertEqual(table.rows[0].cells, ["Name", "Species", "Gender", "Role"])
    XCTAssertTrue(table.rows[0].hasSeparator)
    XCTAssertEqual(table.rows[1].cells, ["Bruce Wayne", "Human", "M", "Batman"])
    XCTAssertFalse(table.rows[1].hasSeparator)
    XCTAssertEqual(table.rows[2].cells, ["Clark Kent", "Kryptonian", "M", "Superman"])
    XCTAssertFalse(table.rows[2].hasSeparator)
    XCTAssertEqual(table.rows[3].cells, ["Diana Prince", "Amazonian", "F", "Wonder Woman"])
    XCTAssertFalse(table.rows[2].hasSeparator)
  }
  
  // MARK: Footnote
  
  func testOnelineFootnote() throws {
    let lines = [
      "[fn:1] footnote one.",
      "",
      "[fn:2] footnote two.",
      ]
    let doc = parse(lines)
    guard let foot1 = doc?.content[0] as? Footnote else {
      XCTFail("Expect \(doc?.content[0]) to be Footnote")
      return
    }
    XCTAssertEqual(foot1.label, "1")
    guard let para1 = foot1.content[0] as? Paragraph else {
      XCTFail("Expect [0][0] to be Paragraph")
      return
    }
    XCTAssertEqual(para1.lines[0], "footnote one.")
  }
  
  func testFootnoteBreaksAfterTwoSpaces() throws {
    let doc = parse([
      "[fn:1] footnote one.",
      "",
      "",
      "[fn:2] footnote two.",
      ])
    
    XCTAssertEqual(2, doc?.content.count)
  }
  
  func testComplexFootnote() throws {
    let lines = [
      "[fn:1] footnote one.",
      "One line of content",
      "",
      "2nd paragraph",
      "",
      "",
      "* a headline",
      ]
    let doc = parse(lines)
    guard let foot = doc?.content[0] as? Footnote else {
      XCTFail("Expect \(doc?.content[0]) to be Footnote")
      return
    }
    guard let para = foot.content[0] as? Paragraph else {
      XCTFail("Expect [0][0] to be Paragraph")
      return
    }
    XCTAssertEqual(para.lines[0], "footnote one.")
    XCTAssertEqual(para.lines[1], "One line of content")
    
    guard let sec = doc?.content[2] as? Section else {
      XCTFail("Expect \(doc?.content[2]) to be Section")
      return
    }
    XCTAssertEqual(sec.title, "a headline")
  }
}
