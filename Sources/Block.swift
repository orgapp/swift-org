//
//  Block.swift
//  SwiftOrg
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

extension OrgParser {
    func parseBlock() throws -> Node {
        guard case let (meta, Token.blockBegin(name, params)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("BlockBegin expected")
        }
        
        tokens.takeSnapshot()
        var block = Block(name: name, params: params)
        var result: Node!
        try self.lookAhead(match: { token in
            if case .blockEnd(let blockEndName) = token {
                return blockEndName.lowercased() == name.lowercased()
            }
            return false
        }, found: { token in
            result = block
        }, notYet: { tokenMeta in
            block.content.append(tokenMeta.raw!)
        }, failed: {
            tokens.restore()
            result = try parseParagraph(meta.raw!)
        })
        return result
    }
}
