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
    public var subList: List?
    
    public init(text t: String? = nil, list l: List? = nil) {
        text = t
        subList = l
    }
    public var description: String {
        return "ListItem(text: \(text), subList: \(subList))"
    }
}

public struct List: Node {
    public var items: [ListItem]
    public var ordered: Bool
    
    public init(ordered o: Bool, items i: [ListItem] = []) {
        ordered = o
        items = i
    }
    
    public var description: String {
        return "List(ordered: \(ordered), items: \(items))"
    }
}
