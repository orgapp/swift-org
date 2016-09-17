//
//  Lexer.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum LexerErrors: Error {
    case tokenizeFailed(Int, String)
}

func t(index: Int = -1, line: String) throws -> TokenWithMeta {
    for (pattern, options, generator) in tokenList {
        if let m = line.match(pattern, options: options) {
            if let token = generator(m) {
                return (TokenMeta(raw: line, lineNumber: index), token)
            }
        }
    }
    throw LexerErrors.tokenizeFailed(index, line)
}

open class Lexer {
    let lines: [String]
    public init(lines ls: [String]) {
        lines = ls
    }
    
    func tokenize() throws -> [TokenWithMeta] {
        defineTokens()
        return try lines.enumerated().map(t)
    }
}
