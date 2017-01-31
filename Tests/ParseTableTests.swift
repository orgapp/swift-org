//
//  ParseTableTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 30/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

class ParseTableTests: XCTestCase {

    func testExample() {
        guard let doc = parse([
            "| Name         | Species    | Gender | Role         |",
            "|--------------+------------+--------+--------------|",
            "| Bruce Wayne  | Human      | M      | Batman       |",
            "| Clark Kent   | Kryptonian | M      | Superman     |",
            "| Diana Prince | Amazonian  | F      | Wonder Woman |",
            ]) else { return }

        XCTAssertEqual(doc.content.count, 1)
        guard let table = doc.content[0] as? Table else {
            XCTFail("Expect 0 to be Table")
            return
        }
        print(table)
        XCTAssertEqual(table.rows.count, 4)
        XCTAssertEqual(table.rows[0].cells, ["Name", "Species", "Gender", "Role"])
        XCTAssertTrue(table.rows[0].hasSeparator)
        XCTAssertEqual(table.rows[1].cells, ["Bruce Wayne", "Human", "M", "Batman"])
        XCTAssertFalse(table.rows[1].hasSeparator)
        XCTAssertEqual(table.rows[2].cells, ["Clark Kent", "Kryptonian", "M", "Superman"])
        XCTAssertFalse(table.rows[2].hasSeparator)
        XCTAssertEqual(table.rows[3].cells, ["Diana Prince", "Amazonian", "F", "Wonder Woman"])
        XCTAssertFalse(table.rows[2].hasSeparator)
    }
}
