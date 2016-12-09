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

public enum Token {
    case setting(key: String, value: String?)
    case headline(stars: Int, text: String?)
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
}

typealias TokenGenerator = ([String?]) -> Token
typealias TokenParing = (Token) -> ((Token) -> Bool)?

struct TokenDescriptor {
    let pattern: String
    let options: NSRegularExpression.Options
    var generator: TokenGenerator
    var pairing: TokenParing
    
    init(_ thePattern: String,
         options theOptions: NSRegularExpression.Options = [],
         pairing thePairing: @escaping TokenParing = { _ in nil },
         generator theGenerator: @escaping TokenGenerator = { matches in .line(text: matches[0]!)}) {
        pattern = thePattern
        options = theOptions
        pairing = thePairing
        generator = theGenerator
    }
}

var tokenDescriptors: [TokenDescriptor] = []

func define(_ pattern: String,
            options: NSRegularExpression.Options = [],
            generator: @escaping TokenGenerator) {
    tokenDescriptors.append(
        TokenDescriptor(pattern,
                        options: options,
                        generator: generator))
}

func advDefine(_ pattern: String,
               options: NSRegularExpression.Options = [],
               that tweak: (TokenDescriptor) -> TokenDescriptor) {
    let td = TokenDescriptor(pattern, options: options)
    tokenDescriptors.append(tweak(td))
}

func defineTokens() {
    if tokenDescriptors.count > 0 {return}
    
//    tokenDescriptors.append(TokenDescriptor("^\\s*$") { _ in .blank })
//    tokenDescriptors.append(
//        TokenDescriptor("^#\\+([a-zA-Z_]+):\\s*(.*)$") { matches in
//            .setting(key: matches[1]!, value: matches[2]) })
    
    define("^\\s*$") { _ in .blank }
    
    define("^#\\+([a-zA-Z_]+):\\s*(.*)$") { matches in
        .setting(key: matches[1]!, value: matches[2]) }
    
    define("^(\\*+)\\s+(.*)$") { matches in
        .headline(stars: matches[1]!.characters.count, text: matches[2]) }
    
    // Block
    
    advDefine("^(\\s*)#\\+begin_([a-z]+)(?:\\s+(.*))?$",
           options: [.caseInsensitive])
    { tokenDescriptor in
        var td = tokenDescriptor
        td.pairing = { token in
            if case .blockBegin(let name, _) = token {
                return { token in
                    if case .blockEnd(let n) = token {
                        return n.lowercased() == name.lowercased()
                    }
                    return false
                }
            }
            return nil
        }
        td.generator = { matches in
            var params: [String]?
            if let m3 = matches[3] {
                params = m3.characters.split{$0 == " "}.map(String.init)
            }
            return .blockBegin(name: matches[2]!, params: params)
        }
        return td
    }
    
    define("^(\\s*)#\\+end_([a-z]+)$", options: [.caseInsensitive]) { matches in
        .blockEnd(name: matches[2]!) }
    
    // Drawer
    
    define("^(\\s*):end:\\s*$", options: [.caseInsensitive]) { _ in .drawerEnd }
    
    advDefine("^(\\s*):([a-z]+):\\s*$",
           options: [.caseInsensitive])
    { tokenDescriptor in
        var td = tokenDescriptor
        td.pairing = { _ in
            return { token in
                if case .drawerEnd = token { return true }
                return false
            }
        }
        td.generator = { matches in
            .drawerBegin(name: matches[2]!)
        }
        return td
    }
    
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
    
    define("^(\\s*)(.*)$") { matches in
        .line(text: matches[2]!) }
    
}

func tokenize(line: String) -> Token? {
    for td in tokenDescriptors {
        guard let m = line.match(td.pattern, options: td.options) else { continue }
        return td.generator(m)
    }
    return nil
}

