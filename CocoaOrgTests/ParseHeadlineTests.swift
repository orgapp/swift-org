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
    
    func testParseDrawer() {
        let lines = [
            "* headline one",
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
        print("+++++++++++++++")
        print(doc)
        print("+++++++++++++++")
    }
    
}
