//
//  Performance.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 16/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import SwiftOrg

class PerformanceTests: XCTestCase {

  var content: String = ""
  override func setUp() {
    super.setUp()
//    let src = "https://raw.githubusercontent.com/xiaoxinghu/dotfiles/master/home.org"
    let src = "https://raw.githubusercontent.com/sachac/.emacs.d/gh-pages/Sacha.org"
    if let url = URL(string: src) {
      do {
        content = try String(contentsOf: url)
      } catch {
        XCTFail("ERROR: \(error)")
      }
    }
  }

  func testLexerPerformance() {
    let lines = content.lines
    print("File size: \(content.characters.count) characters, \(lines.count) lines.")
    let lexer = Lexer()
    self.measure {
      do {
        _ = try lexer.tokenize(lines: lines)
      } catch {
        XCTFail("ERROR: \(error)")
      }
    }
  }

  func testParserPerformance() throws {
    print("File size: \(content.characters.count)")
    let tokens = try Lexer().tokenize(lines: content.lines)
    let parser = OrgParser()
    self.measure {
      do {
        _ = try parser.parse(tokens: tokens)
      } catch {
        XCTFail("ERROR: \(error)")
      }
    }
  }

//  func testTheFileFirst() {
//    print("File size: \(content.characters.count)")
//    do {
//      let parser = OrgParser()
//      let doc = try parser.parse(content: self.content)
//      print("\(doc)")
//    } catch {
//      print(Thread.callStackSymbols)
//      XCTFail("ERROR: \(error)")
//    }
//  }
}
