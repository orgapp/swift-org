//
//  TimestampTests.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 8/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import SwiftOrg

let calendar = Calendar.current

let _date = "2007-01-09"
let _day = "Tue"
let _time = "18:00"
let _repeater = "+2w"

fileprivate func quickDate(date: String, time: String) -> Date {
    let dateParts = date.components(separatedBy: "-").map { Int($0) }
    let timeParts = time.components(separatedBy: ":").map { Int($0) }
    let components = DateComponents(
        calendar: calendar,
        year: dateParts[0],
        month: dateParts[1],
        day: dateParts[2],
        hour: timeParts[0],
        minute: timeParts[1])
    return components.date!
}

class TimestampTests: XCTestCase {

    func testParseTimestamp() {
        let activeTimestamp = "<\(_date) \(_day) \(_time)>"
        if let timestamp = Timestamp.from(string: activeTimestamp) {
            XCTAssertNotNil(timestamp)
            let date = quickDate(date: _date, time: _time)
            XCTAssertEqual(date, timestamp.date)
            XCTAssertTrue(timestamp.active)
        } else {
            XCTFail("Failed to parse \(activeTimestamp)")
            return
        }
        
        let inactiveTimestamp = "[\(_date) \(_day) \(_time)]"
        if let timestamp = Timestamp.from(string: inactiveTimestamp) {
            XCTAssertNotNil(timestamp)
            let date = quickDate(date: _date, time: _time)
            XCTAssertEqual(date, timestamp.date)
            XCTAssertFalse(timestamp.active)
        } else {
            XCTFail("Failed to parse \(inactiveTimestamp)")
            return
        }
    }
    
    func testTimestampWithSpacing() {
        let candidates = [
            "<\(_date) \(_day) \(_time) \(_repeater)>", // normal spacing
            "<\(_date)  \(_day)   \(_time)    \(_repeater)>", // extra spaces in between
            "<  \(_date)  \(_day)   \(_time)    \(_repeater)>", // leading spaces
            "<\(_date)  \(_day)   \(_time)    \(_repeater)    >", // tail spaces
            "<  \(_date)  \(_day)   \(_time)    \(_repeater)    >", // leading & tail spaces
        ]
        
        for str in candidates {
            guard let timestamp = Timestamp.from(string: str) else {
                XCTFail("Failed to parse \(str)")
                return
            }
            let date = quickDate(date: _date, time: _time)
            XCTAssertEqual(date, timestamp.date)
            XCTAssertEqual(_repeater, timestamp.repeater)
        }
    }
    
    func testTimestampWithRepeater() {
        let repeaters = [
            "+2h",
            "+2d",
            "+2w",
            "+2m",
            "+2y",
            "++2d",
            "-2d",
            "--2d",
            ".+2d",
        ]
        
        for repeater in repeaters {
            let str = "[\(_date) \(_day) \(_time) \(repeater)]"
            guard let timestamp = Timestamp.from(string: str) else {
                XCTFail("Failed to parse \(str)")
                return
            }
            let date = quickDate(date: _date, time: _time)
            XCTAssertEqual(date, timestamp.date)
            XCTAssertEqual(repeater, timestamp.repeater)
        }
    }
    
    func testTimestampWithInvalidRepeater() {
        let repeaters = [
            "+2ah",
            "+2week",
            "2+2d",
            "S+2d",
            ]
        
        for repeater in repeaters {
            let str = "[\(_date) \(_day) \(_time) \(repeater)]"
            let timestamp = Timestamp.from(string: str)
            XCTAssertNil(timestamp, "\(str) should be invalid")
        }
    }
    
    func testInvalidTimestamp() {
        let candidates = [
            "[\(_date) \(_day) \(_time) +2a]", // invalid repeater
        ]
        
        for str in candidates {
            let timestamp = Timestamp.from(string: str)
            XCTAssertNil(timestamp, "\(str) should be invalid")
        }
    }

}
