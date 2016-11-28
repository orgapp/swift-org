//
//  Parser.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum Errors: Error {
    case unexpectedToken(String)
}

public class OrgParser {
    // MARK: properties
    var tokens: Queue<TokenWithMeta>!
    var document: OrgDocument!
    public var defaultTodos: [[String]]
    
    // MARK: init
    public init(defaultTodos: [[String]] = [["TODO"], ["DONE"]]) {
        self.defaultTodos = defaultTodos
    }
    
    func skipBlanks() {
        while let token = tokens.peek(), case .blank = token.1 {
            _ = tokens.dequeue()
        }
    }
        
    // MARK: parse document
    func parse(tokens: [TokenWithMeta]) throws -> OrgDocument {
        self.tokens = Queue<TokenWithMeta>(data: tokens)
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
