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
    let dateParts = date.components(separatedBy: "-").map { Int($0) }
    var components = DateComponents(
        calendar: Calendar.current,
        year: dateParts[0],
        month: dateParts[1],
        day: dateParts[2])

    if let t = time {
       let timeParts = t.components(separatedBy: ":").map { Int($0) }
        components.hour = timeParts[0]
        components.minute = timeParts[1]
    }
    return components.date!
}
