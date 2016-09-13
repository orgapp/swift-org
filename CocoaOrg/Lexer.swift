//
//  Lexer.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum LexerErrors: ErrorType {
    case TokenizeFailed(Int, String)
}

public class Lexer {
    let lines: [String]
    public init(lines ls: [String]) {
        lines = ls
    }
    
    func tokenize(index: Int, line: String) throws -> Token {
        
        for (pattern, options, generator) in tokenList {
            if let m = line.match(pattern, options: options) {
                if let token = generator(m, index) {
                    return token
                }
            }
        }
        throw LexerErrors.TokenizeFailed(index, line)
    }
    
    public func tokenize() throws -> [Token] {
        defineTokens()
        var tokens = [Token]()
        for (index, line) in lines.enumerate() {
            let token = try tokenize(index, line: line)
            tokens += [token]
        }
        return tokens
    }
}