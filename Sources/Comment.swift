//
//  Comment.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Comment: Node {
    public let text: String?
    
    public var description: String {
        return "Comment(text: \(text))"
    }
}

