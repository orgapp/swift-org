import Foundation

protocol JSONable {
    func toJSON() -> [String: Any]
}

private extension Array {
    func toJSON() -> [[String: Any]] {
        return self
          .filter { $0 is JSONable }
          .map { ( $0 as! JSONable ).toJSON() }
    }
}

extension OrgDocument: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "document",
          "title": title ?? "",
          "settings": settings,
          "todos": todos,
          "content": content.toJSON()
        ]
    }
}

extension Section: JSONable {
    public func toJSON() -> [String: Any] {
        var dict: [String: Any] = [
          "type": "section",
          "title": title ?? "",
          "stars": stars,
          "content": content.toJSON(),
        ]

        if let drawers = drawers { dict["drawers"] = drawers.toJSON() }
        if let keyword = keyword { dict["keyword"] = keyword }
        if let tags = tags { dict["tags"] = tags }
        if let planning = planning { dict["planning"] = planning.toJSON() }
        return dict
    }
}

extension Paragraph: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "paragraph",
          "text": text,
        ]
    }
}

extension Block: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "block",
          "name": name,
          "params": params ?? [],
          "content": content,
        ]
    }
}

extension List: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "list",
          "ordered": ordered,
          "items": items.toJSON(),
        ]
    }
}

extension ListItem: JSONable {
    public func toJSON() -> [String: Any] {
        
        var dict: [String: Any] = [
          "type": "list_item",
          "text": text ?? "",
        ]
        
        if let subList = subList { dict["sub_list"] = subList.toJSON() }
        return dict
    }
}

extension Comment: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "comment",
          "text": text ?? "",
        ]
    }
}

extension Drawer: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "drawer",
          "name": name,
          "content": content,
        ]
    }
}

extension Footnote: JSONable {
    public func toJSON() -> [String: Any] {
        return [
          "type": "footnote",
          "label": label,
          "content": content.toJSON(),
        ]
    }
}

extension Planning: JSONable {
    public func toJSON() -> [String: Any] {
        var dict: [String: Any] = [
          "type": "planning",
          "keyword": keyword.rawValue,
        ]
        if let timestamp = timestamp { dict["timestamp"] = timestamp.toJSON() }
        return dict
    }
}

extension Timestamp: JSONable {
    public func toJSON() -> [String : Any] {
        var dict: [String: Any] = [
            "active": active,
            "date": date.description,
        ]
        if let repeater = repeater { dict["repeater"] = repeater }
        return dict
    }
}

extension HorizontalRule: JSONable {
    public func toJSON() -> [String : Any] {
        return [ "type": "horizontal_rule" ]
    }
}

extension Table.Row: JSONable {
    public func toJSON() -> [String : Any] {
        return [
            "has_seperator": hasSeparator,
            "cells": cells,
        ]
    }
}

extension Table: JSONable {

    public func toJSON() -> [String : Any] {
        return [
            "rows": rows.toJSON()
        ]
    }
}
