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
    
    
    /// look ahead for matching tokens
    ///
    /// - Parameters:
    ///   - index: start index
    ///   - match: matcher
    ///   - found: callback when found the target
    ///   - notYet: callback for not yet
    ///   - Failed: failed to find the match
    /// - Throws: Lexer Error
    func lookAhead(
        index: Int,
        match: (Token) -> Bool,
        found: (Int, Token, String) -> Void,
        notYet: (String) -> Void,
        Failed: () -> Void) throws {
        if index == lines.count {
            Failed()
            return
        }
        
        let line = lines[index]
        guard let token = Lexer.tokenize(line: line) else {
            throw LexerErrors.tokenizeFailed(index, line)
        }
        
        if match(token) {
            found(index, token, line)
        } else {
            notYet(line)
            try lookAhead(index: index + 1, match: match, found: found, notYet: notYet, Failed: Failed)
        }
    }
    
    func tokenize(cursor: Int = 0, tokens: [Token] = []) throws -> [Token] {
        
        if lines.count == cursor { return tokens }
        let line = lines[cursor]
        
        guard let token = Lexer.tokenize(line: line) else {
            throw LexerErrors.tokenizeFailed(cursor, line)
        }
        var newTokens = tokens
        
        guard let pProcessor = pairing(token) else {
            newTokens.append(token)
            return try tokenize(cursor: cursor + 1, tokens: newTokens)
        }
        
        var newCursor = cursor + 1
        var tmpTokens = newTokens
        tmpTokens.append(token)
        
        try lookAhead(index: cursor + 1,
                      match: pProcessor.closureMatcher,
                      found: { index, t, l in
                        tmpTokens.append(t)
                        newTokens = tmpTokens
                        newCursor = index + 1
        }, notYet: { tmpTokens.append(pProcessor.contentToken($0)) },
           Failed: { newTokens.append(pProcessor.fallbackToken(line)) })
        return try tokenize(cursor: newCursor, tokens: newTokens)        
    }
}
