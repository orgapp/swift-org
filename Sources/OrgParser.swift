//
//  Parser.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum Errors: Error {
    case unexpectedToken(String)
    case cannotFindToken(String)
}

public class OrgParser {
    // MARK: properties
    var tokens: Queue<TokenInfo>!
    var document: OrgDocument!
    public var defaultTodos: [[String]]
    
    // MARK: init
    public init(defaultTodos: [[String]] = [["TODO"], ["DONE"]]) {
        self.defaultTodos = defaultTodos
    }
    
    func skipBlanks() {
        while let (_, token) = tokens.peek(), case .blank = token {
            _ = tokens.dequeue()
        }
    }
    
    /// look ahead for matching tokens
    ///
    /// - Parameters:
    ///   - match: matcher
    ///   - found: callback when found the target
    ///   - notYet: callback for not yet
    ///   - Failed: failed to find the match
    /// - Throws: Lexer Error
    func lookAhead(
        match: (Token) -> Bool,
        found: (Token) -> Void,
        notYet: (TokenMeta) -> Void,
        failed: () throws -> Void) throws {
        
        guard let (meta, token) = tokens.dequeue() else {
            try failed()
            return
        }
        
        if match(token) {
            found(token)
        } else {
            notYet(meta)
            try lookAhead(match: match, found: found, notYet: notYet, failed: failed)
        }
    }
    
    // MARK: parse document
    func parse(tokens: [TokenInfo]) throws -> OrgDocument {
        self.tokens = Queue<TokenInfo>(data: tokens)
        document = OrgDocument(todos: defaultTodos)
        return try parseDocument()
    }
    
    public func parse(lines: [String]) throws -> OrgDocument {
        let lexer = Lexer(lines: lines)
        return try parse(tokens: lexer.tokenize())
    }
    
    public func parse(content: String) throws -> OrgDocument {
        return try parse(lines: content.lines)
    }
}
