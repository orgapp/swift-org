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
}
