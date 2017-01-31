//
//  Queue.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 30/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

internal struct Queue<T> {
    var array = [T]()
    var snapshot: [T]?
    
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
    
    mutating func swapNext(with element: T) {
        _ = dequeue()
        array.insert(element, at: 0)
    }
    
    func peek() -> T? {
        return array.first
    }
    
    mutating func takeSnapshot() {
        snapshot = array
    }
    
    mutating func restore() {
        if let s = snapshot {
            array = s
        }
    }
}

extension Queue : CustomStringConvertible {
    internal var description: String {
        return array.map{i in "\(i)"}.joined(separator: "\n")
    }
}
