//
//  Utils.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import CocoaOrg

func tokenize(line: String) -> Token? {
    do {
        return try t(line: line).1
    } catch {
        XCTFail("\(error)")
        return nil
    }
}

func parse(_ lines: [String]) -> OrgNode? {
    do {
        let parser = try Parser(lines: lines)
        return try parser.parse()
    } catch {
        XCTFail("> ERROR: \(error).")
    }
    return nil
}
