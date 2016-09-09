//
//  Matchers.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation
import CocoaOrg
import Nimble

func beSetting(key: String, value: String?) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <Setting(\"\(key)\", \"\(value)\")>"
        if let actual = try expression.evaluate(),
            case let .Setting(k ,v) = actual {
            return key == k && value == v
        }
        return false
    }
}

func beHeader(level: Int, text: String?) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <Header(\"\(level)\", \"\(text)\")>"
        if let actual = try expression.evaluate(),
            case let .Header(l ,t) = actual {
            return level == l && text == t
        }
        return false
    }
}

func beLine(text: String) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <Line(\"\(text)\")>"
        if let actual = try expression.evaluate(),
            case let .Line(t) = actual {
            return text == t
        }
        return false
    }
}

func beBlockBegin(type: String, params: [String]?) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <BlockBegin(\"\(type)\", \"\(params)\")>"
        if let actual = try expression.evaluate(),
            case let .BlockBegin(t, p) = actual {
            return type == t && (params == nil ? p == nil : params! == p!)
        }
        return false
    }
}

func beBlockEnd(type: String) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <BlockBegin(\"\(type)\")>"
        if let actual = try expression.evaluate(),
            case let .BlockEnd(t) = actual {
            return type == t
        }
        return false
    }
}

func beComment(text: String) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <Comment(\"\(text)\")>"
        if let actual = try expression.evaluate(),
            case let .Comment(t) = actual {
            return text == t
        }
        return false
    }
}

func beRaw(text: String) -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <Raw(\"\(text)\")>"
        if let actual = try expression.evaluate(),
            case let .Raw(t) = actual {
            return text == t
        }
        return false
    }
}

func beBlank() -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <Blank>"
        if let actual = try expression.evaluate() {
            if case .Blank = actual {
                return true
            }
        }
        return false
    }
}

func beHorizontalRule() -> MatcherFunc<Token> {
    return MatcherFunc { expression, message in
        message.postfixMessage = "be <HorizontalRule>"
        if let actual = try expression.evaluate() {
            if case .HorizontalRule = actual {
                return true
            }
        }
        return false
    }
}