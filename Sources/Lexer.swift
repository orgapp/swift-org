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

open class Lexer {
    let lines: [String]
    public init(lines theLines: [String]) {
        lines = theLines
        defineTokens()
    }
    
    func lookAhead(
        index: Int,
        match: (Token) -> Bool,
        found: (Int, Token, String) -> Void,
        notYet: (Int, String) -> Void,
        Failed: () -> Void) throws {
        if index == lines.count {
            Failed()
            return
        }
        
        let line = lines[index]
        guard let token = SwiftOrg.tokenize(line: line) else {
            throw LexerErrors.tokenizeFailed(index, line)
        }
        
        if match(token) {
            found(index, token, line)
        } else {
            notYet(index, line)
            try lookAhead(index: index + 1, match: match, found: found, notYet: notYet, Failed: Failed)
        }
    }
    
    func tokenize(cursor: Int = 0, tokens: [Token] = []) throws -> [Token] {
        
        if lines.count == cursor { return tokens }
        let line = lines[cursor]
        
        for td in tokenDescriptors {
            guard let m = line.match(td.pattern, options: td.options) else { continue }
            let token = td.generator(m)
            
            var newTokens = tokens
            
            guard let pairing = td.pairing(token) else {
                newTokens.append(token)
                return try tokenize(cursor: cursor + 1, tokens: newTokens)
            }
            
            var newCursor = cursor + 1
            var tmpTokens = newTokens
            tmpTokens.append(token)
            
            try lookAhead(index: cursor + 1,
                          match: pairing,
                          found: { index, t, l in
                            tmpTokens.append(t)
                            newTokens = tmpTokens
                            newCursor = index + 1
            }, notYet: { index, l in
                tmpTokens.append(.line(text: l))
            }, Failed: {
                newTokens.append(.line(text: line))
            })
            return try tokenize(cursor: newCursor, tokens: newTokens)
        }
        throw LexerErrors.tokenizeFailed(cursor, line)

        
//        guard let token = SwiftOrg.tokenize(line: line) else {
//            throw LexerErrors.tokenizeFailed(cursor, line)
//        }

        
    }
}
