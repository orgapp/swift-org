//
//  Paragraph.swift
//  CocoaOrg
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
