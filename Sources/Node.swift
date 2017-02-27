//
//  Nodes.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

/// Index of elements within org file.
public struct OrgIndex: CustomStringConvertible, Hashable {
    var indexes: [Int]

    public init(_ theIndexes: [Int] = [0]) {
        indexes = theIndexes
    }

    public var out: OrgIndex {
        var newIndex = indexes
        newIndex.removeLast()
        return OrgIndex(newIndex)
    }

    public var `in`: OrgIndex {
        var newIndex = indexes
        newIndex.append(0)
        return OrgIndex(newIndex)
    }

    public var next: OrgIndex {
        var newIndex = indexes
        newIndex[newIndex.endIndex - 1] = newIndex.last! + 1
        return OrgIndex(newIndex)
    }

    public var prev: OrgIndex {
        var newIndex = indexes
        newIndex[newIndex.endIndex - 1] = newIndex.last! - 1
        return OrgIndex(newIndex)
    }

    public var description: String {
        return indexes.map { n in
            return "\(n)"
            }.joined(separator: ".")
    }

    public var hashValue: Int {
        return description.hashValue
    }

    public static func == (lhs: OrgIndex, rhs: OrgIndex) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public protocol Node: CustomStringConvertible {
    var index: OrgIndex? { get }
}

extension Node {
    public var index: OrgIndex? { return nil }
}

extension OrgParser {
    func parseTheRest() throws -> Node? {
        guard let (_, token) = tokens.peek() else {
            return nil
        }
        switch token {
        case .blank:
            _ = tokens.dequeue()
            return nil
        case .line:
            return try parseParagraph()
        case let .comment(t):
            _ = tokens.dequeue()
            return Comment(text: t)
        case .blockBegin:
            return try parseBlock()
        case .drawerBegin:
            return try parseDrawer()
        case .listItem:
            return try parseList()
        case .planning(let keyword, let timestamp):
            _ = tokens.dequeue()
            return Planning(keyword: keyword, timestamp: timestamp)
        case .tableRow, .horizontalSeparator:
            return try parseTable()
        case .horizontalRule:
            _ = tokens.dequeue()
            return HorizontalRule()
        default:
            throw Errors.unexpectedToken("\(token) is not expected")
        }
    }
}
