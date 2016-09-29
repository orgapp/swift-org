//
//  OrgFileWriterTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 29/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class OrgFileWriterTests: XCTestCase {

    var doc: OrgDocument?
    
    override func setUp() {
        super.setUp()
        do {
            let path = Bundle(for: type(of: self)).path(forResource: "README", ofType: "org")
            let content = try String(contentsOfFile: path!)
            let parser = OrgParser()
            doc = try parser.parse(content: content)

        } catch {
            XCTFail("ERROR: \(error)")
        }
    }

    func testOrgFileWriter() {
        let text = doc!.toText()
        print(text)
    }
    
}
