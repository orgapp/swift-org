//
//  ParserTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 27/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class ParseParagraphTests: XCTestCase {
    
    func testParseParagraph() {
        let lines = [
            "Line one.",
            "Line two.",
            "Line three.",
            "",
            "Line four.",
            "Line five.",
            ]
        let doc = parse(lines)
        guard let para1 = doc?.children[0].value as? Paragraph else {
            XCTFail("Expect 0 to be Paragraph")
            return
        }
        XCTAssertEqual(para1.lines.count, 3)
        XCTAssertEqual(para1.lines, ["Line one.", "Line two.", "Line three."])
        
        guard let para2 = doc?.children[2].value as? Paragraph else {
            XCTFail("Expect 0 to be Paragraph")
            return
        }
        XCTAssertEqual(para2.lines.count, 2)
        XCTAssertEqual(para2.lines, ["Line four.", "Line five."])
    }

}
