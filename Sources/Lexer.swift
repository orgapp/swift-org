//
//  Lexer.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum LexerErrors: Error {
    case tokenizeLineFailed(String)
    case tokenizeFailed(Int, String)
}

func t(line: String) -> Token? {
    for (pattern, options, generator) in tokenList {
        guard let m = line.match(pattern, options: options) else { continue }
        return generator(m)
    }
    return nil
}

open class Lexer {
    let lines: [String]
    public init(lines ls: [String]) {
        lines = ls
        defineTokens()
    }
    
    func lookAhead(
        index: Int,
        for: (Token) -> Bool,
        match: (Int, Token, String) -> Void,
        notYet: (Int, String) -> Void,
        Failed: () -> Void) throws {
        if index == lines.count {
            Failed()
            return
        }
        
        let line = lines[index]
        guard let token = t(line: line) else {
            throw LexerErrors.tokenizeFailed(index, line)
        }
        
        if `for`(token) {
            match(index, token, line)
        } else {
            notYet(index, line)
            try lookAhead(index: index + 1, for: `for`, match: match, notYet: notYet, Failed: Failed)
        }
    }
    
    func tokenize(cursor: Int = 0, tokens: [TokenWithMeta] = []) throws -> [TokenWithMeta] {
        
        if lines.count == cursor { return tokens }
        let line = lines[cursor]
        guard let token = t(line: line) else {
            throw LexerErrors.tokenizeFailed(cursor, line)
        }
        var newTokens = tokens
        
        guard let pair = pairing(token) else {
            newTokens.append((TokenMeta(raw: line, lineNumber: cursor), token))
            return try tokenize(cursor: cursor + 1, tokens: newTokens)
        }
        
        var newCursor = cursor + 1
        var tmpTokens = newTokens
        tmpTokens.append((TokenMeta(raw: line, lineNumber: cursor), token))
        
        try lookAhead(index: cursor + 1,
                  for: pair,
                  match: { index, t, l in
                    tmpTokens.append((TokenMeta(raw: l, lineNumber: index), t))
                    newTokens = tmpTokens
                    newCursor = index + 1
        }, notYet: { index, l in
            tmpTokens.append((TokenMeta(raw: l, lineNumber: index), .line(text: l)))
        }, Failed: {
            newTokens.append((TokenMeta(raw: line, lineNumber: cursor), .line(text: line)))
        })
        return try tokenize(cursor: newCursor, tokens: newTokens)
        
    }
}
