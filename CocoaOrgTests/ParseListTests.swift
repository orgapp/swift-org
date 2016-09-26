//
//  ListTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class ParseListTests: XCTestCase {
    
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
}
