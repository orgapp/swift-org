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
        guard let d = doc.lookUp(DocumentMeta.self) else {
            XCTFail("Cannot find Document root.")
            return
        }
        XCTAssertEqual(d.settings.count, 1)
        XCTAssertEqual(d.settings["options"], "toc:nil")
        XCTAssertNil(d.settings["TITLE"])
    }
}
