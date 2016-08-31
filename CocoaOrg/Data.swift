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

