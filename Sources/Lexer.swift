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
  
}
