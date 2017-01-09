//
//  HeadlineTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
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

class ParseHeadlineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
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
            ]) else { XCTFail("failed to parse lines."); return }

        eval(doc.content[0]) { sec in
            XCTAssertEqual(sec.tags!, ["tag1"])
        }
        eval(doc.content[1]) { sec in
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
    
}
