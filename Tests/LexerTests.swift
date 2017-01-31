//
//  LexerTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 8/12/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import SwiftOrg

class LexerTests: XCTestCase {

    func testTokenBlock() throws {
        let lexer = Lexer(lines: [
            "| hello | world | y'all |",
            ])

        let tokens = try lexer.tokenize()
         print("--------------------------------------")
         print("\(tokens)")
         print("--------------------------------------")
    }


}
