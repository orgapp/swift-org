//
//  Data.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 31/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

internal extension Array {
    func toQueue() -> Queue<Element> {
        return Queue<Element>(data: self)
    }
}

open class TreeNode<T> {
    open var value: T
    open var parent: TreeNode?
    open var children = [TreeNode<T>]()
    public init(value v: T) {
        value = v
    }
    
    func add(_ child: TreeNode<T>) -> TreeNode<T> {
        children.append(child)
        child.parent = self
        return child
    }
    
    func add(_ child: T) -> TreeNode<T> {
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
    
    open func lookUp<Type>(_ type: Type.Type) -> Type? {
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
        let prefix = String(repeating: "-", count: depth)
        var lines = ["\(prefix) \(value)"]
        if !children.isEmpty {
            lines += children.map { $0.description }
        }
        return lines.joined(separator: "\n")
    }
}

public struct Progress {
    public var total: Int = 0
    public var done: Int = 0
    
    public init(_ d: Int = 0, outof t: Int = 0) {
        total = t
        done = d
    }
}

extension Progress: Equatable {
    public static func ==(lhs: Progress, rhs: Progress) -> Bool {
        return lhs.total == rhs.total && lhs.done == rhs.done
    }
}
