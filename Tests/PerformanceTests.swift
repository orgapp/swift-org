//
//  Performance.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 16/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

class PerformanceTests: XCTestCase {
    
    var content: String = ""
    override func setUp() {
        super.setUp()
        do {
            let path = Bundle(for: type(of: self)).path(forResource: "README", ofType: "org")
            content = try String(contentsOfFile: path!)
        } catch {
            XCTFail("ERROR: \(error)")
        }
    }
    
    func testPerformanceParseSmallFile() {
        self.measure {
            do {
                let parser = OrgParser()
                _ = try parser.parse(content: self.content)
            } catch {
                XCTFail("ERROR: \(error)")
            }
        }
    }
}
