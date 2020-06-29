//
//  String.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 15/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public func multiline(_ x: String...) -> String {
    return x.joined(separator: "\n")
}

extension String {
    var lines: [String] { return self.components(separatedBy: CharacterSet.newlines) }
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func indent(_ n: Int) -> String {
        return "\(String(repeating: " ", count: n))\(self)"
    }
}

func length(_ text: String?) -> Int {
    return (text ?? "").count
}
