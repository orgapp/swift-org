//
//  ParserTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 27/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class ParserTests: XCTestCase {
    func parse(_ lines: [String]) -> OrgNode? {
        do {
            let parser = try Parser(lines: lines)
            return try parser.parse()
        } catch {
            XCTFail("> ERROR: \(error).")
        }
        return nil
    }
    
    func testParseSettings() {
        guard let doc = self.parse([
            "#+options: toc:nil",
            "#+TITLE: ",
            "  ",
            "* First Head Line",
            ]) else { return }
        guard let d = doc.lookUp(DocumentMeta.self) else {
            XCTFail("Cannot find Document root.")
            return
        }
        XCTAssertEqual(d.settings.count, 1)
        XCTAssertEqual(d.settings["options"], "toc:nil")
        XCTAssertNil(d.settings["TITLE"])
    }
    
    func testParseHeadline() {
        guard let doc = self.parse([
            "#+TODO: NEXT",
            "* Header 1",
            "* TODO Header 2",
            "  A line of content.",
            "** Header 2.1",
            "*** Header 2.1.1",
            "** Header 2.2",
            "* NEXT Customized todo",
            "* "
            ]) else { return }
        XCTAssertEqual(doc.children.count, 4)
        
        let h1Section = doc.children[0]
        guard let h1 = h1Section.value as? Section else {
            XCTFail("Expect nodes[0] to be Section")
            return
        }
        XCTAssertEqual(h1.level, 1)
        XCTAssertEqual(h1.title, "Header 1")
        XCTAssertEqual(h1Section.children.count, 0)
        
        let h2Section = doc.children[1]
        guard let h2 = h2Section.value as? Section else {
            XCTFail("Expect nodes[1] to be Section")
            return
        }
        XCTAssertEqual(h2.level, 1)
        XCTAssertEqual(h2.title, "Header 2")
        XCTAssertEqual(h2.state, "TODO")
        XCTAssertEqual(h2Section.children.count, 3)
        
        guard let line = h2Section.children[0].value as? Paragraph else {
            XCTFail("Expect h2.nodes[0] to be Line")
            return
        }
        XCTAssertEqual(line.text, "A line of content.")
        
        let h3Section = doc.children[2]
        guard let h3 = h3Section.value as? Section else {
            XCTFail("Expect nodes[1] to be Section")
            return
        }
        XCTAssertEqual(h3.title, "Customized todo")
        XCTAssertEqual(h3.state, "NEXT")
        
        let h4Section = doc.children[3]
        guard let h4 = h4Section.value as? Section else {
            XCTFail("Expect nodes[1] to be Section")
            return
        }
        XCTAssertNil(h4.title)
        XCTAssertNil(h4.state)

    }
    
    func testParseParagraph() {
        let lines = [
            "Line one.",
            "Line two.",
            "Line three.",
            "",
            "Line four.",
            "Line five.",
            ]
        let doc = self.parse(lines)
        guard let para1 = doc?.children[0].value as? Paragraph else {
            XCTFail("Expect 0 to be Paragraph")
            return
        }
        XCTAssertEqual(para1.lines.count, 3)
        XCTAssertEqual(para1.lines, ["Line one.", "Line two.", "Line three."])
        
        guard let para2 = doc?.children[2].value as? Paragraph else {
            XCTFail("Expect 0 to be Paragraph")
            return
        }
        XCTAssertEqual(para2.lines.count, 2)
        XCTAssertEqual(para2.lines, ["Line four.", "Line five."])
        print(doc)
    }
    
    func testParseBlock() {
        guard let doc = self.parse([
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
        
        XCTAssertEqual(doc.children.count, 6)
        guard let block1 = doc.children[0].value as? Block else {
            XCTFail("Expect 0 to be Block")
            return
        }
        XCTAssertEqual(block1.type, "src")
        XCTAssertEqual(block1.params!, ["java"])
        XCTAssertEqual(block1.content, ["  class HelloWorld {", "  # print(\"Hell World\");", "  }"])
        guard let block2 = doc.children[1].value as? Block else {
            XCTFail("Expect 1 to be Block")
            return
        }
        XCTAssertEqual(block2.type, "src")
        XCTAssertNil(block2.params)
        guard let block3 = doc.children[2].value as? Block else {
            XCTFail("Expect 2 to be Block")
            return
        }
        XCTAssertEqual(block3.type, "src")
        XCTAssertEqual(block3.params!, ["yaml", "exports:", "results",  ":results",  "value", "html"])
        guard let comment = doc.children[3].value as? Comment else {
            XCTFail("Expect 3 to be Comment")
            return
        }
        XCTAssertEqual(comment.text, "+begin_src java")
        
        // TODO make these assertion work
        //                expect(doc.children[4].value).to(beAnInstanceOf(Paragraph))
        //                expect(doc.children[5].value).to(beAnInstanceOf(Comment))
    }
    
    func testParseList() {
        let lines = [
            "- list item",
            " 1. sub list item",
            " 1.  sub list item",
            "- list item",
            ]
        let doc = self.parse(lines)
        guard let list = doc?.children[0].value as? List else {
            XCTFail("Expect 0 to be List")
            return
        }
        XCTAssertEqual(list.items.count, 2)
        XCTAssertFalse(list.ordered)
        XCTAssertEqual(list.items[0].text, "list item")
        XCTAssertEqual(list.items[1].text, "list item")
        XCTAssertNil(list.items[1].list)
        
        guard let subList = list.items[0].list else {
            XCTFail("Expecting sublist")
            return
        }
        XCTAssertEqual(subList.items.count, 2)
        XCTAssertTrue(subList.ordered)
        XCTAssertEqual(subList.items[0].text, "sub list item")
        XCTAssertEqual(subList.items[1].text, "sub list item")
    }
    
    func testInlineParsing() {
        // TODO finish this
        let text = "hello *world*, and /Welcome/ to *org* world. and [[http://google.com][this]] is a link. and [[/image/logo.png][this]] is a image."
        //                let splitted = text.matchSplit("(\\*)([\\s\\S]*?)\\1", options: [])
        let lexer = InlineLexer(text: text)
        let tokens = lexer.tokenize()
        for _ in tokens {
            //                    print("-- \(t)")
        }
    }
}
