//
//  Lexer.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum LexerErrors: Error {
  case tokenizeFailed(Int, String)
}

open class Lexer {
  
  var tokens = [TokenInfo]()
  
  /// Tokenize one line, without considering the context
  ///
  /// - Parameter line: the target line
  /// - Returns: the token
  class func tokenize(line: String) -> Token? {
    for td in tokenDescriptors {
      guard let m = line.match(td.pattern, options: td.options) else { continue }
      return td.generator(m)
    }
    return nil
  }
  
  class func tokenize(text: String, range: NSRange, callback: (Token) -> Void) {
    for td in tokenDescriptors {
      guard let m = td.expression.firstMatch(in: text, options: [], range: range) else { continue }
      
      var matches = [String?]()
      switch m.numberOfRanges {
      case let n where n > 0:
        for i in 0..<n {
          let r = m.rangeAt(i)
          matches.append(r.length > 0 ? NSString(string: text).substring(with: r) : nil)
        }
      default: ()
      }

      let token = td.generator(matches)
      callback(token)
      let newStart = m.range.location + m.range.length
      
      let newRange = NSMakeRange(newStart, text.utf16.count - newStart)
      tokenize(text: text, range: newRange, callback: callback)
    }
  }
  
  func tokenize(lines: [String]) throws -> [TokenInfo] {
    defineTokens()
    var tokens = [TokenInfo]()
    for (index, line) in lines.enumerated() {
      guard let token = Lexer.tokenize(line: line) else {
        throw LexerErrors.tokenizeFailed(index, line)
      }
      tokens.append((TokenMeta(raw: line, lineNumber: index), token))
    }
    return tokens
  }
  
  func _tokenize(text: String) throws -> [TokenInfo] {
    defineTokens()
    var tokens = [TokenInfo]()
    Lexer.tokenize(text: text, range: NSMakeRange(0, text.utf16.count)) { token in
      tokens.append((TokenMeta(raw: "", lineNumber: 0), token))
    }
    return tokens
  }
}
