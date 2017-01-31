//
//  List.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct ListItem: Node {
    public let text: String?
    public var checked: Bool?
    public var subList: List?
    
    public init(text t: String? = nil, checked c: Bool? = nil, list l: List? = nil) {
        text = t
        subList = l
        checked = c
    }
    public var description: String {
        return "ListItem(text: \(text), checked: \(checked), subList: \(subList))"
    }
}

public struct List: Node {
    public var items: [ListItem]
    public var ordered: Bool
    public var progress: Progress {
        var progress = Progress()
        for item in items {
            if let checked = item.checked {
                progress.total += 1
                if checked {
                    progress.done += 1
                }
            }
        }
        return progress
    }
    
    public init(ordered o: Bool, items i: [ListItem] = []) {
        ordered = o
        items = i
    }
    
    public var description: String {
        return "List(ordered: \(ordered), items: \(items))"
    }
}

extension OrgParser {
    func parseList() throws -> List {
        guard case let (_, Token.listItem(indent, text, ordered, checked)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("ListItem expected")
        }
        var list = List(ordered: ordered)
        list.items = [ListItem(text: text, checked: checked)]
        while let (_, token) = tokens.peek() {
            if case let .listItem(i, t, _, c) = token {
                if i > indent {
                    var lastItem = list.items.removeLast()
                    lastItem.subList = try parseList()
                    list.items += [lastItem]
                } else if i == indent {
                    _ = tokens.dequeue()
                    list.items += [ListItem(text: t, checked: c)]
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return list
    }
}
