import Foundation

protocol JSONable {
    func toJSON() -> [String: Any?]
}

private extension Array {
    func toJSON() -> [[String: Any?]] {
        return self
          .filter { $0 is JSONable }
          .map { ( $0 as! JSONable ).toJSON() }
    }
}

extension OrgDocument: JSONable {
    func toJSON() -> [String: Any?] {
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
    func toJSON() -> [String: Any?] {
        var dict: [String: Any?] = [
          "type": "section",
          "title": title ?? "",
          "stars": stars,
          "keyword": keyword,
          "tags": tags,
          "planning": planning?.toJSON(),
          "content": content.toJSON(),
        ]

        if let drawers = drawers {
            dict["drawers"] = drawers.toJSON()
        }
        return dict
    }
}

extension Paragraph: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "paragraph",
          "text": text,
        ]
    }
}

extension Block: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "block",
          "name": name,
          "params": params ?? [],
          "content": content,
        ]
    }
}

extension List: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "list",
          "ordered": ordered,
          "items": items.toJSON(),
        ]
    }
}

extension ListItem: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "list_item",
          "text": text,
          "sub_list": subList?.toJSON()
        ]
    }
}

extension Comment: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "comment",
          "text": text,
        ]
    }
}

extension Drawer: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "drawer",
          "name": name,
          "content": content,
        ]
    }
}

extension Footnote: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "footnote",
          "label": label,
          "content": content.toJSON(),
        ]
    }
}

extension Planning: JSONable {
    func toJSON() -> [String: Any?] {
        return [
          "type": "planning",
          "keyword": keyword.rawValue,
          "timestamp": timestamp?.toJSON(),
        ]
    }
}

extension Timestamp: JSONable {
    func toJSON() -> [String : Any?] {
        return [
            "active": active,
            "repeater": repeater,
            "date": date.description,
        ]
    }
}

extension HorizontalRule: JSONable {
    func toJSON() -> [String : Any?] {
        return [ "type": "horizontal_rule" ]
    }
}

extension Table.Row: JSONable {
    func toJSON() -> [String : Any?] {
        return [
            "has_seperator": hasSeparator,
            "cells": cells,
        ]
    }
}

extension Table: JSONable {

    func toJSON() -> [String : Any?] {
        return [
            "rows": rows.toJSON()
        ]
    }
}
