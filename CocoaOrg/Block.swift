//
//  Block.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Block: Node {
    public let name: String
    public let params: [String]?
    public var content: [String] = []
    
    public init(name n: String, params p: [String]? = nil) {
        name = n
        params = p
    }
    
    public var description: String {
        return "Block(name: \(name), params: \(params), content: \(content))"
    }
}
