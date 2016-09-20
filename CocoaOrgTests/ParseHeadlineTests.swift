//
//  HeadlineTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class ParseHeadlineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testParseHeadline() {
        guard let doc = parse([
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
        print(doc)
        XCTAssertEqual(doc.content.count, 4)
        
        guard let h1 = doc.content[0] as? Section else {
            XCTFail("Expect nodes[0] to be Section")
            return
        }
        XCTAssertEqual(h1.level, 1)
        XCTAssertEqual(h1.title, "Header 1")
        XCTAssertEqual(h1.content.count, 0)
        
        guard let h2 = doc.content[1] as? Section else {
            XCTFail("Expect nodes[1] to be Section")
            return
        }
        XCTAssertEqual(h2.level, 1)
        XCTAssertEqual(h2.title, "Header 2")
        XCTAssertEqual(h2.state, "TODO")
        XCTAssertEqual(h2.content.count, 3)
        
        guard let line = h2.content[0] as? Paragraph else {
            XCTFail("Expect h2.nodes[0] to be Line")
            return
        }
        XCTAssertEqual(line.text, "A line of content.")
        
        guard let h3 = doc.content[2] as? Section else {
            XCTFail("Expect nodes[1] to be Section")
            return
        }
        XCTAssertEqual(h3.title, "Customized todo")
        XCTAssertEqual(h3.state, "NEXT")
        
        guard let h4 = doc.content[3] as? Section else {
            XCTFail("Expect nodes[1] to be Section")
            return
        }
        XCTAssertNil(h4.title)
        XCTAssertNil(h4.state)
        
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
        print(doc)
        
        guard let section = doc?.content[0] as? Section else {
            XCTFail("Expect Section")
            return
        }
        XCTAssertNotNil(section.drawers)
        XCTAssertEqual(section.drawers?.count, 2)
        XCTAssertEqual(section.drawers?[0].name, "LOGBOOK")
        XCTAssertEqual(section.drawers?[1].name, "PROPERTIES")
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

        guard let section = doc?.content[0] as? Section else {
            XCTFail("Expect Section")
            return
        }
        
        XCTAssertNil(section.drawers)
//        XCTAssertEqual(section.content.count, 2)
    }
    
}
