//
//  String.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 15/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public func multiline(x: String...) -> String {
    return x.joinWithSeparator("\n")
}

extension String {
    var lines: [String] { return self.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) }
    var trimmed: String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}

func length(text: String?) -> Int {
    return (text ?? "").characters.count
}