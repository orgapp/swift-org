//
//  ParseSettingTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

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
}
