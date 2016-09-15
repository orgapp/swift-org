//
//  Tokens.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 13/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct TokenMeta {
    public let raw: String?
    public let lineNumber: Int
}

protocol CommonToken {
    var meta: TokenMeta {get}
}

public enum Token {
    case setting(TokenMeta, key: String, value: String?)
    case header(TokenMeta, level: Int, text: String?)
    case blank(TokenMeta)
    case horizontalRule(TokenMeta)
    case blockBegin(TokenMeta, type: String, params: [String]?)
    case blockEnd(TokenMeta, type: String)
    case listItem(TokenMeta, indent: Int, text: String?, ordered: Bool)
    case comment(TokenMeta, String?)
    case line(TokenMeta, text: String)
    case raw(TokenMeta)
}

extension Token: CommonToken {
    var meta: TokenMeta {
        switch self {
        case .setting(let meta, _, _):
            return meta
        case .header(let meta, _, _):
            return meta
        case .blank(let meta):
            return meta
        case .horizontalRule(let meta):
            return meta
        case .blockBegin(let meta, _, _):
            return meta
        case .blockEnd(let meta, _):
            return meta
        case .listItem(let meta, _, _, _):
            return meta
        case .comment(let meta, _):
            return meta
        case .line(let meta, _):
            return meta
        case .raw(let meta):
            return meta
        }
    }
}

typealias TokenGenerator = ([String?], Int) -> Token?

var tokenList: [(String, NSRegularExpression.Options, TokenGenerator)] = []

func define(_ pattern: String, options: NSRegularExpression.Options = [], generator: @escaping TokenGenerator) {
    tokenList.append((pattern, options, generator))
//    tokenList += [
//        (pattern, options, generator)
//    ]
}

func defineTokens() {
    if tokenList.count > 0 {return}
    
    define("^\\s*$") { matches, lineNumber in
        .blank(TokenMeta(raw: matches[0], lineNumber: lineNumber)) }
    define("^#\\+([a-zA-Z_]+):\\s*(.*)$") { matches, lineNumber in
        .setting(TokenMeta(raw: matches[0], lineNumber: lineNumber), key: matches[1]!, value: matches[2]) }
    define("^(\\*+)\\s+(.*)$") { matches, lineNumber in
        .header(TokenMeta(raw: matches[0], lineNumber: lineNumber),
                level: matches[1]!.characters.count, text: matches[2]) }
    define("^(\\s*)#\\+begin_([a-z]+)(:?\\s+(.*))?$", options: [.caseInsensitive]) { matches, lineNumber in
        var params: [String]?
        let meta = TokenMeta(raw: matches[0], lineNumber: lineNumber)
        if let m3 = matches[3] {
            params = m3.characters.split{$0 == " "}.map(String.init)
        }
        return .blockBegin(meta, type: matches[2]!, params: params) }
    define("^(\\s*)#\\+end_([a-z]+)$", options: [.caseInsensitive]) { matches, lineNumber in
        .blockEnd(TokenMeta(raw: matches[0], lineNumber: lineNumber), type: matches[2]!) }
    define("^(\\s*)[-+*]\\s+(.*)$") { matches, lineNumber in
        .listItem(TokenMeta(raw: matches[0], lineNumber: lineNumber),
                  indent: length(matches[1]), text: matches[2], ordered: false) }
    define("^(\\s*)\\d+(?:\\.|\\))\\s+(.*)$") { matches, lineNumber in
        .listItem(TokenMeta(raw: matches[0], lineNumber: lineNumber), indent: length(matches[1]), text: matches[2], ordered: true) }
    define("^\\s*-{5,}$") { matches, lineNumber in
        .horizontalRule(TokenMeta(raw: matches[0]!, lineNumber: lineNumber)) }
    define("^\\s*#\\s+(.*)$") { matches, lineNumber in
        .comment(TokenMeta(raw: matches[0], lineNumber: lineNumber), matches[1]) }
    define("^(\\s*)(.*)$") { matches, lineNumber in
        .line(TokenMeta(raw: matches[0], lineNumber: lineNumber), text: matches[2]!) }
}
