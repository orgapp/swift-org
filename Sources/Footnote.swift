//
//  Footnote.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 27/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Footnote: Node {
    public var label: String
    public var content: [Node] = []
    
    public var description: String {
        return "Footnote(content: \(content))"
    }
}

extension OrgParser {
    func parseFootnote() throws -> Footnote {
        guard case let(_, .footnote(label, content)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("footnote expected")
        }
        
        var footnote = Footnote(label: label, content: [try parseParagraph(content)!])
        while let (_, token) = tokens.peek() {
            switch token {
            case .headline, .footnote:
                return footnote
            default:
                if let n = try parseTheRest() {
                    footnote.content.append(n)
                }
            }
        }
        return footnote
    }
}
