//
//  InlineParser.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 29/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum InlineToken {
    case bold(String)
    case italic(String)
    case underlined(String)
    case strikeThrough(String)
    case verbatim(String)
    case code(String)
    case link(text: String, url: String)
    case plain(String)
    case footnote(String)
}

typealias InlineTokenGenerator = (String) -> InlineToken
let markerList: [(String, InlineTokenGenerator)] = [
    ("~", { text in .code(text) }),
    ("=", { text in .verbatim(text) }),
    ("*", { text in .bold(text) }),
    ("/", { text in .italic(text) }),
    ("_", { text in .underlined(text) }),
    ("+", { text in .strikeThrough(text) }),
]

open class InlineLexer {
    
    var text: String
    var tokens: [InlineToken]
    var attr: [String : AnyObject] = [String : AnyObject]()
    public init(text t: String) {
        text = t
        tokens = [InlineToken.plain(text)]
    }
    
    fileprivate func tokenizeEmphasis() {
        for (marker, generator) in markerList {
            var newTokens = [InlineToken]()
            for token in tokens {
                if case let InlineToken.plain(text) = token {
                    text.tryMatch("([\(marker)]+)([\\s\\S]+?)\\1", match: { m in
                        newTokens.append(generator(m[2]!))
                        }, or: { text in newTokens.append(.plain(text)) })
                } else {
                    newTokens.append(token)
                }
            }
            tokens = newTokens
        }
    }
    
    fileprivate func tokenizeLink() {
        var newTokens = [InlineToken]()
        for token in tokens {
            if case let InlineToken.plain(text) = token {
                text.tryMatch("\\[\\[([^\\]]*)\\](?:\\[([^\\]]*)\\])?\\]", match: { m in
                    newTokens.append(.link(text: m[2]!, url: m[1]!))
                    }, or: { text in newTokens.append(.plain(text)) })
            } else {
                newTokens.append(token)
            }
        }
        tokens = newTokens
    }
    
    fileprivate func tokenizeFootnote() {
        var newTokens = [InlineToken]()
        for token in tokens {
            if case let InlineToken.plain(text) = token {
                text.tryMatch("\\[fn:(\\d+)\\]", match: { m in
                    newTokens += [.footnote(m[1]!)]
                    }, or: { text in newTokens.append(.plain(text)) })
            } else {
                newTokens += [token]
            }
        }
        tokens = newTokens
    }
    
    open func tokenize() -> [InlineToken] {
        tokens = [InlineToken.plain(text)]
        tokenizeLink()
        tokenizeEmphasis()
        tokenizeFootnote()
        return tokens
    }
}
