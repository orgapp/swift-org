//
//  JsonConverter.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

func toDict(_ node: Node) -> [String: Any] {
    var json = [String: Any]()
    if let doc = node as? OrgDocument {
        json["title"] = doc.title
        json["settings"] = doc.settings
        json["todos"] = doc.todos
        json["content"] = doc.content.map { n in toDict(n) }
    }
    if let section = node as? Section {
        json["type"] = "section"
        json["title"] = section.title
        json["level"] = section.level
        json["state"] = section.state
        if let drawers = section.drawers {
            json["drawers"] = drawers.map { n in toDict(n) }
        }
        json["content"] = section.content.map { n in toDict(n) }
    }
    if let paragraph = node as? Paragraph {
        json["type"] = "paragraph"
        json["lines"] = paragraph.lines
    }
    if let block = node as? Block {
        json["type"] = "block"
        json["name"] = block.name
        json["params"] = block.params
        json["content"] = block.content
    }
    if let list = node as? List {
        json["type"] = "list"
        json["ordered"] = list.ordered
        json["items"] = list.items.map { n in toDict(n) }
    }
    if let listItem = node as? ListItem {
        json["type"] = "listItem"
        json["text"] = listItem.text
        if let subList = listItem.subList {
            json["subList"] = toDict(subList)
        }
    }
    if let comment = node as? Comment {
        json["type"] = "comment"
        json["text"] = comment.text
    }
    if let drawer = node as? Drawer {
        json["name"] = drawer.name
        json["content"] = drawer.content
    }
    return json
}

extension OrgDocument {
    public func toJson(options: JSONSerialization.WritingOptions) throws -> String {
        let json = toDict(self)
        let data = try JSONSerialization.data(withJSONObject: json, options: options)
        return String(data: data, encoding: .utf8)!
    }
}
