//
//  IndexingTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/11/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

fileprivate func eval(_ node: Node?, makesure: (Section) -> Void) {
    if let doc = node as? OrgDocument {
        doc.content.forEach { n in
            eval(n, makesure: makesure)
        }
        return
    }
    guard let section = node as? Section else {
        XCTFail("Section is expected")
        return
    }
    XCTAssertNotNil(section.index)
    print(">> eval: \(section.index!)")
//    print("   hash: \(section.index!.hashValue)")
    makesure(section)
    for n in section.content {
        if let subSection = n as? Section {
            eval(subSection, makesure: makesure)
        }
    }
}

class IndexingTests: XCTestCase {
    
    func testIndexing() {
        let index = OrgIndex([0, 1, 2])
        XCTAssertEqual(index.in.description, "0.1.2.0")
        XCTAssertEqual(index.out.description, "0.1")
        XCTAssertEqual(index.next.description, "0.1.3")
        XCTAssertEqual(index.prev.description, "0.1.1")
    }
    
    func testSectionIndexing() {
        guard let doc = parse([
            "* Section 0",
            "** Section 0.0",
            "** Section 0.1",
            "*** Section 0.1.0",
            "*** Section 0.1.1",
            "*** Section 0.1.2",
            "**** Section 0.1.2.0",
            "* Section 1",
            "* Section 2",
            ]) else { XCTFail("failed to parse lines."); return }

        eval(doc) { section in
            XCTAssertEqual("Section \(section.index!.description)", section.title)
        }
    }
}
