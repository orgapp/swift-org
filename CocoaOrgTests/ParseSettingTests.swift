//
//  ParseSettingTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class ParseSettingTests: XCTestCase {
    
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
    
    func testTodos() {
        guard let doc = parse([
            "#+TODO: TODO NEXT | DONE CANCELED",
            "#+TITLE: ",
            "  ",
            "* First Head Line",
            ]) else { return }
        ["TODO", "NEXT", "DONE", "CANCELED"].forEach { keyword in
            XCTAssert(doc.todos.contains(keyword))
        }
    }
}
