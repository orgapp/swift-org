//
//  List.swift
//  CocoaOrg
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
