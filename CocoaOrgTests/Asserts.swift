//
//  Asserts.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 15/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import CocoaOrg

func expect(_ actual: Token, toBe expected: Token,
            file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expected, actual,
                   file: file, line: line)
}


func evalListItem(_ content: String, indent: Int, text: String?, ordered: Bool, checked: Bool? = nil,
          file: StaticString = #file, line: UInt = #line) {
    
    let token = tokenize(line: content)
    expect(token!, toBe: .listItem(indent: indent, text: text, ordered: ordered, checked: checked),
           file: file, line: line)
}

func evalHorizontalRule(_ content: String,
                        file: StaticString = #file, line: UInt = #line) {
        let token = tokenize(line: content)
        expect(token!, toBe: .horizontalRule,
               file: file, line: line)
}

func evalComment(_ content: String, text: String,
                        file: StaticString = #file, line: UInt = #line) {
        let token = tokenize(line: content)
        expect(token!, toBe: .comment(text),
               file: file, line: line)
}

func evalBlockEnd(_ content: String, type: String,
                  file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .blockEnd(name: type),
           file: file, line: line)
}

func evalBlockBegin(_ content: String, type: String, params: [String]?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .blockBegin(name: type, params: params),
           file: file, line: line)
}

func evalHeadline(_ content: String, level: Int, text: String?,
                    file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .headline(level: level, text: text),
           file: file, line: line)
}

func evalSetting(_ content: String, key: String, value: String?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .setting(key: key, value: value),
           file: file, line: line)
}

func evalBlank(_ content: String, rawIsNil: Bool = false,
                 file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .blank,
           file: file, line: line)
}

func evalLine(_ content: String, text: String,
              file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .line(text: text),
           file: file, line: line)
}

func evalDrawerBegin(_ content: String, name: String,
              file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .drawerBegin(name: name),
           file: file, line: line)
}

func evalDrawerEnd(_ content: String,
                     file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .drawerEnd,
           file: file, line: line)
}
