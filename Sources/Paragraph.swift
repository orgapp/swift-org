//
//  Paragraph.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Paragraph: Node {
    public var lines: [String]
    public var text: String {
        return lines.joined(separator: " ")
    }
    public var parsed: [InlineToken] {
        return InlineLexer(text: text).tokenize()
    }
    
    public var description: String {
        return "Paragraph(text: \(text))"
    }
}

extension OrgParser {
    func parseParagraph(_ startWith: String? = nil) throws -> Paragraph? {
        var paragraph: Paragraph? = nil
        if let firstLine = startWith {
            paragraph = Paragraph(lines: [firstLine])
        }
        while let (_, token) = tokens.peek() {
            if case .line(let t) = token {
                paragraph = paragraph ?? Paragraph(lines: [])
                paragraph?.lines.append(t)
                _ = tokens.dequeue()
            } else {
                break
            }
        }
        return paragraph
    }
}
