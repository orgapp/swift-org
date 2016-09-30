//
//  InlineParsingTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import CocoaOrg

class InlineParsingTests: XCTestCase {
    
    func testInlineParsing() {
        // TODO impl tests
        let text = "hello *world*, and /Welcome/ to *org* world. and [[http://google.com][this]] is a link. and [[/image/logo.png][this]] is a image."
        //                let splitted = text.matchSplit("(\\*)([\\s\\S]*?)\\1", options: [])
        let lexer = InlineLexer(text: text)
        let tokens = lexer.tokenize()
        for _ in tokens {
            //                    print("-- \(t)")
        }
    }
    
    func testInlineFootnote() {
        let text = "This is a footnote right here[fn:1]. And this is the rest of the line."
        let lexer = InlineLexer(text: text)
        let tokens = lexer.tokenize()
        for t in tokens {
            print("-- \(t)")
        }
    }
}
