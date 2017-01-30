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
    let lines: [String]
    public init(lines theLines: [String]) {
        lines = theLines
    }
    
    
    /// Tokenize one line, without considering the context
    ///
    /// - Parameter line: the target line
    /// - Returns: the token
    class func tokenize(line: String) -> Token? {
        defineTokens()
        for td in tokenDescriptors {
            guard let m = line.match(td.pattern, options: td.options) else { continue }
            return td.generator(m)
        }
        return nil
    }
    
    func tokenize(cursor: Int = 0, tokens: [TokenInfo] = []) throws -> [TokenInfo] {
        
        if lines.count == cursor { return tokens }
        let line = lines[cursor]
        
        guard let token = Lexer.tokenize(line: line) else {
            throw LexerErrors.tokenizeFailed(cursor, line)
        }
        
        return try tokenize(
            cursor: cursor + 1,
            tokens: tokens + [(TokenMeta(raw: line, lineNumber: cursor), token)])
    }
}
