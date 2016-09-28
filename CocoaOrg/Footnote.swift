//
//  Footnote.swift
//  CocoaOrg
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
