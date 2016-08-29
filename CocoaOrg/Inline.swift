//
//  InlineParser.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 29/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum InlineToken {
    case Bold(String)
    case Italic(String)
    case Underlined(String)
    case StrikeThrough(String)
    case Verbatim(String)
    case Code(String)
    case Link(text: String, url: String)
    case Plain(String)
}

typealias InlineTokenGenerator = (String) -> InlineToken
let markerList: [(String, InlineTokenGenerator)] = [
    ("~", { text in .Code(text) }),
    ("=", { text in .Verbatim(text) }),
    ("*", { text in .Bold(text) }),
    ("/", { text in .Italic(text) }),
    ("_", { text in .Underlined(text) }),
    ("+", { text in .StrikeThrough(text) }),
]

public class InlineLexer {
    
    var text: String
    var tokens: [InlineToken]
    var attr: [String : AnyObject] = [String : AnyObject]()
    public init(text t: String) {
        text = t
        tokens = [InlineToken.Plain(text)]
    }
    
    private func tokenizeEmphasis() {
        for (marker, generator) in markerList {
            var newTokens = [InlineToken]()
            for token in tokens {
                if case let InlineToken.Plain(text) = token {
                    text.tryMatch("([\(marker)])([\\s\\S]*?)\\1", match: { m in
                        newTokens.append(generator(m[2]!))
                        }, or: { text in newTokens.append(.Plain(text)) })
                } else {
                    newTokens.append(token)
                }
            }
            tokens = newTokens
        }
    }
    
    private func tokenizeLink() {
        var newTokens = [InlineToken]()
        for token in tokens {
            if case let InlineToken.Plain(text) = token {
                text.tryMatch("\\[\\[([^\\]]*)\\](?:\\[([^\\]]*)\\])?\\]", match: { m in
                    newTokens.append(.Link(text: m[2]!, url: m[1]!))
                    }, or: { text in newTokens.append(.Plain(text)) })
            } else {
                newTokens.append(token)
            }
        }
        tokens = newTokens
    }
    
    public func tokenize() -> [InlineToken] {
        tokens = [InlineToken.Plain(text)]
        tokenizeLink()
        tokenizeEmphasis()
        return tokens
    }
}