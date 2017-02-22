//
//  Utils.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import Foundation
@testable import SwiftOrg

let parser = OrgParser()

func parse(_ lines: [String], with parser: OrgParser = parser) -> OrgDocument? {
    do {
        return try parser.parse(lines: lines)
    } catch {
        XCTFail("> ERROR: \(error).")
    }
    return nil
}

func quickDate(date: String, time: String? = nil) -> Date {
    let formater = DateFormatter()
    formater.dateFormat = "yyyy-MM-dd"
    var dt = date
    if let t = time {
        dt = "\(date) \(t)"
        formater.dateFormat = "yyyy-MM-dd HH:mm"
    }
    return formater.date(from: dt)!
}
