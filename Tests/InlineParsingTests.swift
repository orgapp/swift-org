//
//  InlineParsingTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

class InlineParsingTests: XCTestCase {
    
    func testInlineParsing() {
        let text = "hello *world*, and /Welcome/ to *org* world. and [[http://google.com][this]] is a link. and [[/image/logo.png][this]] is a image."
        //                let splitted = text.matchSplit("(\\*)([\\s\\S]*?)\\1", options: [])
        let lexer = InlineLexer(text: text)
        let tokens = lexer.tokenize()
        var index = 0
        XCTAssertEqual(tokens[index], .plain("hello ")); index += 1
        XCTAssertEqual(tokens[index], .bold("world")); index += 1
        XCTAssertEqual(tokens[index], .plain(", and ")); index += 1
        XCTAssertEqual(tokens[index], .italic("Welcome")); index += 1
        XCTAssertEqual(tokens[index], .plain(" to ")); index += 1
        XCTAssertEqual(tokens[index], .bold("org")); index += 1
        XCTAssertEqual(tokens[index], .plain(" world. and ")); index += 1
        XCTAssertEqual(tokens[index], .link(text: "this", url: "http://google.com")); index += 1
        XCTAssertEqual(tokens[index], .plain(" is a link. and ")); index += 1
        XCTAssertEqual(tokens[index], .link(text: "this", url: "/image/logo.png")); index += 1
        XCTAssertEqual(tokens[index], .plain(" is a image.")); index += 1
        XCTAssertEqual(tokens.count, index)
    }
    
    func testCornerCases() {
        let text = "hello **world** ****world****"
        let tokens = InlineLexer(text: text).tokenize()
        for t in tokens {
            print(t)
        }
        var index = 0
        XCTAssertEqual(tokens[index], .plain("hello ")); index += 1
        XCTAssertEqual(tokens[index], .bold("world")); index += 1
        XCTAssertEqual(tokens[index], .plain(" ")); index += 1
        XCTAssertEqual(tokens[index], .bold("world")); index += 1
        XCTAssertEqual(tokens.count, index)
    }
    
    func testInlineFootnote() {
        let text = "This is a footnote right here[fn:1]. And this is the rest of the line."
        let tokens = InlineLexer(text: text).tokenize()
        
        var index = 0
        XCTAssertEqual(tokens[index], .plain("This is a footnote right here")); index += 1
        XCTAssertEqual(tokens[index], .footnote("1")); index += 1
        XCTAssertEqual(tokens[index], .plain(". And this is the rest of the line.")); index += 1
        XCTAssertEqual(tokens.count, index)
    }
}
