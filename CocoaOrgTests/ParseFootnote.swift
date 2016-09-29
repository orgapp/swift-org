//
//  ParseFootnote.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 28/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class ParseFootnote: XCTestCase {
    func testOnelineFootnote() throws {
        let lines = [
            "[fn:1] footnote one.",
            "",
            "[fn:2] footnote two.",
            ]
        let doc = parse(lines)
        guard let foot1 = doc?.content[0] as? Footnote else {
            XCTFail("Expect \(doc?.content[0]) to be Footnote")
            return
        }
        XCTAssertEqual(foot1.label, "1")
        guard let para1 = foot1.content[0] as? Paragraph else {
            XCTFail("Expect [0][0] to be Paragraph")
            return
        }
        XCTAssertEqual(para1.lines[0], "footnote one.")
    }
}
