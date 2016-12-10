//
//  TokenExtensions.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 15/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import SwiftOrg

//extension TokenMeta: Equatable {
//    public static func ==(lhs: TokenMeta, rhs: TokenMeta) -> Bool {
//        return lhs.lineNumber == rhs.lineNumber && lhs.raw == rhs.raw
//    }
//}

extension Token: Equatable {
    public static func ==(lhs: Token, rhs: Token) -> Bool {
        return "\(lhs)" == "\(rhs)"
//        switch (lhs, rhs) {
//        case (.blank(let lMeta), .blank(let rMeta)) where lMeta == rMeta: return true
//        case (let .setting(lMeta, lKey, lValue), let .setting(rMeta, rKey, rValue))
//            where lMeta == rMeta && lKey == rKey && lValue == rValue: return true
//        case (let .headline(lMeta, lLevel, lText), let .header(rMeta, rLevel, rText))
//            where lMeta == rMeta && lLevel == rLevel && lText == rText: return true
//        default: return "\(lhs)" == "\(rhs)"
//        }
    }
}

extension InlineToken: Equatable {
    public static func ==(lhs: InlineToken, rhs: InlineToken) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }
}
