//
//  Data.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 31/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

internal struct Queue<T> {
    var array = [T]()
    
    init(data: [T]) {
        array = data
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        }
        return array.removeFirst()
    }
    
    func peek() -> T? {
        return array.first
    }
}

internal extension Array {
    func toQueue() -> Queue<Element> {
        return Queue<Element>(data: self)
    }
}

public class TreeNode<T> {
    public var value: T
    public var parent: TreeNode?
    public var children = [TreeNode<T>]()
    public init(value v: T) {
        value = v
    }
    
    func add(child: TreeNode<T>) -> TreeNode<T> {
        children.append(child)
        child.parent = self
        return child
    }
    
    func add(child: T) -> TreeNode<T> {
        let c = TreeNode<T>(value: child)
        c.parent = self
        children.append(c)
        return c
    }
    
    var isLeaf: Bool {
        return children.count == 0
    }
    
    var isRoot: Bool {
        return parent == nil
    }
    
    var depth: Int {
        if let p = parent {
            return p.depth + 1
        }
        return 0
    }
    
    public func lookUp<Type>(type: Type.Type) -> Type? {
        if let v = value as? Type {
            return v
        }
        if let p = parent {
            return p.lookUp(type)
        }
        return nil
    }
}

extension TreeNode: CustomStringConvertible {
    public var description: String {
        let prefix = String(count: depth, repeatedValue: Character("-"))
        var lines = ["\(prefix) \(value)"]
        if !children.isEmpty {
            lines += children.map { $0.description }
        }
        return lines.joinWithSeparator("\n")
    }
}
