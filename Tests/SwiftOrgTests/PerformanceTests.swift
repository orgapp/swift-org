//
//  Performance.swift
//  SwiftOrg
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
    let src = "https://raw.githubusercontent.com/xiaoxinghu/dotfiles/master/home.org"
//    let src = "https://raw.githubusercontent.com/sachac/.emacs.d/gh-pages/Sacha.org"
    if let url = URL(string: src) {
      do {
        content = try String(contentsOf: url)
      } catch {
        XCTFail("ERROR: \(error)")
      }
    }
  }
  
//  func testPerformanceParseSmallFile() {
//    print("File size: \(content.characters.count)")
//    self.measure {
//      do {
//        let parser = OrgParser()
//        let doc = try parser.parse(content: self.content)
//        print("\(doc.title!)")
//      } catch {
//        XCTFail("ERROR: \(error)")
//      }
//    }
//  }
  
  func testTheFileFirst() {
    print("File size: \(content.characters.count)")
    do {
      let parser = OrgParser()
      let doc = try parser.parse(content: self.content)
      print("\(doc.title!)")
    } catch {
      print(Thread.callStackSymbols)
      XCTFail("ERROR: \(error)")
    }
  }
}
