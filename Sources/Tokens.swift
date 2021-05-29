//
//  Tokens.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 13/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation


public struct TokenMeta {
    public let raw: String?
    public let lineNumber: Int
}

typealias TokenInfo = (TokenMeta, Token)

public enum Token {
    case setting(key: String, value: String?)
    case headline(stars: Int, text: String?)
    case planning(keyword: PlanningKeyword, timestamp: Timestamp?)
    case blank
    case horizontalRule
    case blockBegin(name: String, params: [String]?)
    case blockEnd(name: String)
    case drawerBegin(name: String)
    case drawerEnd
    case listItem(indent: Int, text: String?, ordered: Bool, checked: Bool?)
    case comment(String?)
    case line(text: String)
    case footnote(label: String, content: String?)
    case tableRow(cells: [String])
    case horizontalSeparator
    case raw(String)
}

typealias TokenGenerator = ([String?]) -> Token

struct TokenDescriptor {
    let pattern: String
    let options: RegularExpression.Options
    let generator: TokenGenerator


    init(_ thePattern: String,
         options theOptions: RegularExpression.Options = [],
         generator theGenerator: @escaping TokenGenerator = { matches in .raw(matches[0]!) }) {
        pattern = thePattern
        options = theOptions
        generator = theGenerator
    }
}

func define(_ pattern: String,
            options: RegularExpression.Options = [],
            generator: @escaping TokenGenerator) {
    tokenDescriptors.append(
        TokenDescriptor(pattern,
                        options: options,
                        generator: generator))
}

var tokenDescriptors: [TokenDescriptor] = []

func defineTokens() {
    if tokenDescriptors.count > 0 {return}

    define("^\\s*$") { _ in .blank }

    define("^#\\+([a-zA-Z_]+):\\s*(.*)$") { matches in
        .setting(key: matches[1]!, value: matches[2]) }

    define("^(\\*+)\\s+(.*)$") { matches in
        .headline(stars: matches[1]!.count, text: matches[2]) }

    define("^\\s*(\(PlanningKeyword.all.joined(separator: "|"))):\\s+(.+)$") { matches in
        let timestamp = Timestamp.from(string: matches[2]!)
        return .planning(keyword: PlanningKeyword(rawValue: matches[1]!)!, timestamp: timestamp)
    }
    // Block
    define("^(\\s*)#\\+begin_([a-z]+)(?:\\s+(.*))?$",
           options: [.caseInsensitive])
    { matches in
        var params: [String]?
        if let m3 = matches[3] {
            params = m3.split{$0 == " "}.map(String.init)
        }
        return .blockBegin(name: matches[2]!, params: params)
    }

    define("^(\\s*)#\\+end_([a-z]+)$", options: [.caseInsensitive]) { matches in
        .blockEnd(name: matches[2]!) }

    // Drawer

    define("^(\\s*):end:\\s*$", options: [.caseInsensitive]) { _ in .drawerEnd }

    define("^(\\s*):([a-z]+):\\s*$",
           options: [.caseInsensitive]) { matches in
            .drawerBegin(name: matches[2]!) }

    define("^(\\s*)([-+*]|\\d+(?:\\.|\\)))\\s+(?:\\[([ X-])\\]\\s+)?(.*)$") { matches in
        var ordered = true
        if let m = matches[2] {
            ordered = !["-", "+", "*"].contains(m)
        }
        var checked: Bool? = nil
        if let m = matches[3] {
            checked = m == "X"
        }
        return .listItem(indent: length(matches[1]), text: matches[4], ordered: ordered, checked: checked) }

    define("^\\s*-{5,}$") { _ in .horizontalRule }

    define("^\\s*#\\s+(.*)$") { matches in
        .comment(matches[1]) }

    define("^\\[fn:(\\d+)\\](?:\\s+(.*))?$") { matches in
        .footnote(label: matches[1]!, content: matches[2])
    }

    // Table

    define("\\s*\\|-.*$") { matches in
        return .horizontalSeparator
    }

    define("^\\s*\\|(?:[^\\r\\n\\|]*\\|?)+$") { matches in
        let cells = matches[0]!
            .components(separatedBy: "|")
            .map { $0.trimmed }
            .filter { !$0.isEmpty }
        return .tableRow(cells: cells)
    }

    define("^(\\s*)(.*)$") { matches in
        .line(text: matches[2]!) }

}
