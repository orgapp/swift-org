//
//  OrgDocument.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct OrgDocument: NodeContainer, Affiliatable {
  // alias getter for attributes
  public var settings: [String: String] {
    return attributes
  }
  
  public var index: OrgIndex? {
    return OrgIndex([])
  }
  
  public var attributes = [String : String]()
  
  var _attributes = [String : String]()
  public var content = [Node]()
  
  public var title: String? {
    return settings["TITLE"]
  }
  
  public let defaultTodos: [[String]]
  
  public var todos: [[String]] {
    if let todo = settings["TODO"] {
      let keywords = todo.components(separatedBy: .whitespaces)
      var result: [[String]] = [[]]
      for keyword in keywords {
        if keyword == "|" {
          result.append([])
        } else {
          result[result.endIndex - 1].append(keyword)
        }
      }
      return result
    }
    return defaultTodos
  }
  
  public init(todos: [[String]]) {
    defaultTodos = todos
  }
  
  public var description: String {
    return "OrgDocument(settings: \(settings))\n - \(content)"
  }
}

extension OrgParser {
    
  func parseDocument() throws -> OrgDocument {
    document = preProcess()
    document = try parse(under: document) as! OrgDocument
    document.attributes.merge(with: orphanAttributes)
    return document
  }
  
  fileprivate func preProcess() -> OrgDocument {
    document = OrgDocument(todos: defaultTodos)
    document = tokens.array.reduce(document!) {
      if case let .setting(key, value) = $1.1,
        isIBS(key) {
        var doc = $0
        doc.attributes[key] = value
        return doc
      }
      return $0
    }
    return document
  }
}
