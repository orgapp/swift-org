//
//  ConvertToJSONTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 27/02/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

class ConvertToJSONTests: XCTestCase {
    func testJSONConvertion() throws {
        let lines = [
            "#+TITLE: Org Mode Syntax",
            "#+TODO: TODO NEXT | DONE",
            "",
            "* TODO Section One         :tag1:tag2:",
            "  DEADLINE: <2017-02-28 Tue>",
            "  :PROPERTIES:",
            "  :CATEGORY: nice",
            "  :END:",
            "",
            "  Fist line of a paragraph.",
            "  Second line of a paragraph.",
            "-----",
            "| Name         | Species    | Gender | Role         |",
            "|--------------+------------+--------+--------------|",
            "| Bruce Wayne  | Human      | M      | Batman       |",
            "| Clark Kent   | Kryptonian | M      | Superman     |",
            "| Diana Prince | Amazonian  | F      | Wonder Woman |",
            "-----",
            "- list item one",
            "- list item tow",
            "  - list item tow.one",
            "-----",
            "#+BEGIN_SRC swift",
            "print(\"org-mode is awesome.\")",
            "#+END_SRC",
            "-----",
            "# This is a comment.",
            "* Section Two",
            "** Section Two.One",
        ]

        let doc = parse(lines)
        let json = doc?.toJSON()
        XCTAssertEqual(json?["type"] as? String, "document")
        XCTAssertEqual(json?["title"] as? String, "Org Mode Syntax")
        
        guard let todos = json?["todos"] as? [[String]] else {
            XCTFail("should have todos")
            return
        }
        XCTAssertEqual(todos.count, 2)
        XCTAssertEqual(todos[0], ["TODO", "NEXT"])
        XCTAssertEqual(todos[1], ["DONE"])

        guard let settings = json?["settings"] as? [String: String] else {
            XCTFail("should have settings")
            return
        }
        
        XCTAssertEqual(settings["TITLE"], "Org Mode Syntax")
        XCTAssertEqual(settings["TODO"], "TODO NEXT | DONE")
        
        guard let content = json?["content"] as? [[String: Any?]] else {
            XCTFail("should have content")
            return
        }
        
        XCTAssertEqual(content.count, 2)
        
        
        let section1 = content[0]
        
        XCTAssertEqual(section1["title"] as? String, "Section One")
        XCTAssertEqual(section1["type"] as? String, "section")
        XCTAssertEqual(section1["stars"] as? Int, 1)
        XCTAssertEqual(section1["keyword"] as? String, "TODO")
        
        guard let tags = section1["tags"] as? [String] else {
            XCTFail("should have tags")
            return
        }
        XCTAssertEqual(tags, ["tag1", "tag2"])
        
        guard let planning = section1["planning"] as? [String: Any?] else {
            XCTFail("should have planning")
            return
        }
        
        XCTAssertEqual(planning["type"] as? String, "planning")
        XCTAssertEqual(planning["keyword"] as? String, "DEADLINE")
        
        guard let drawers = section1["drawers"] as? [[String: Any?]] else {
            XCTFail("should have drawers")
            return
        }
        
        XCTAssertEqual(drawers.count, 1)
        XCTAssertEqual(drawers[0]["type"] as? String, "drawer")
        XCTAssertEqual(drawers[0]["name"] as? String, "PROPERTIES")
        XCTAssertEqual((drawers[0]["content"] as? [String])!, ["  :CATEGORY: nice"]) // TODO properly parse properties
        
        // TODO finish the rest
    }
}
