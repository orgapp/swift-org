//
//  Section.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Section: NodeContainer, Affiliatable {
  
  // MARK: properties
  public var index: OrgIndex?
  public var attributes = [String : String]()
  public var title: String?
  public var stars: Int
  public var keyword: String?
  public var priority: Priority?
  public var tags: [String]?
  public var content = [Node]()
  
  public var drawers: [Drawer]? {
    let ds = content.filter { node in
      return node is Drawer
      }.map { node in
        return node as! Drawer
    }
    return ds
  }
  
  public var planning: Planning? {
    return content.first { $0 is Planning } as? Planning
  }
  
  // MARK: func
  public init(stars l: Int, title t: String?, todos: [String]) {
    stars = l
    // TODO limit charset on tags
    let pattern = "^(?:(\(todos.joined(separator: "|")))\\s+)?(?:\\[#([ABCabc])\\]\\s+)?(.*?)(?:\\s+((?:\\:.+)+\\:)\\s*)?$"
    if let text = t, let m = text.match(pattern) {
      keyword = m[1]
      if let p = m[2] {
        priority = Priority(rawValue: p.uppercased())
      }
      title = m[3]
      if let t = m[4] {
        tags = t.components(separatedBy: ":").filter({ !$0.isEmpty })
      }
    } else {
      title = t
    }
  }
  
  public var description: String {
    return "Section[\(index)](stars: \(stars), keyword: \(keyword)), priority: \(priority)), title: \(title)\n - tags: \(tags)\n - \(drawers)\n - \(content)"
  }
}

public struct Planning: Node {
  public let keyword: PlanningKeyword
  public let timestamp: Timestamp?
  
  public var description: String {
    return "Planning(keyword: \(keyword), timestamp: \(timestamp))"
  }
}

extension OrgParser {
  
  func parseSection() throws -> Section {
    guard case let (_, Token.headline(l, t)) = tokens.dequeue()! else {
      throw Errors.unexpectedToken("headline expected")
    }
    var section = Section(stars: l, title: t, todos: document.todos.flatMap{ $0 })
    if let attr = attrBuffer {
      section.attributes = attr
      attrBuffer = nil
    }
    return section
  }
}
