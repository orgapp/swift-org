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
        guard case let Token.blockBegin(name, params) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("BlockBegin expected")
        }
        var block = Block(name: name, params: params)
        while let token = tokens.dequeue() {
            switch token {
            case let .blockEnd(n):
                if n.lowercased() != name.lowercased() {
                    throw Errors.unexpectedToken("Expecting BlockEnd of type \(name), but got \(n)")
                }
                return block
            case .raw(let text):
                block.content.append(text)
            default:
                throw Errors.unexpectedToken("\(token)")
            }
        }
        throw Errors.cannotFindToken("BlockEnd")
    }
}
