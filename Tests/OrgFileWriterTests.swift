//
//  OrgFileWriterTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 29/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

class OrgFileWriterTests: XCTestCase {

    func testOrgFileWriter() throws {
        
        let path = Bundle(for: type(of: self)).path(forResource: "README", ofType: "org")
        let content = try String(contentsOfFile: path!)
        let parser = OrgParser()
        let doc = try parser.parse(content: content)

        let text = doc.toText()
        print(text)
    }
    
}
