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


func evalListItem(_ content: String, indent: Int, text: String?, ordered: Bool,
          file: StaticString = #file, line: UInt = #line) {
    
        let token = tokenize(line: content)
        expect(token!, toBe: .listItem(TokenMeta(raw: content, lineNumber: -1),
                                      indent: indent, text: text, ordered: ordered),
               file: file, line: line)
}

func evalHorizontalRule(_ content: String,
                        file: StaticString = #file, line: UInt = #line) {
        let token = tokenize(line: content)
        expect(token!, toBe: .horizontalRule(TokenMeta(raw: content, lineNumber: -1)),
               file: file, line: line)
}

func evalComment(_ content: String, text: String,
                        file: StaticString = #file, line: UInt = #line) {
        let token = tokenize(line: content)
        expect(token!, toBe: .comment(TokenMeta(raw: content, lineNumber: -1), text),
               file: file, line: line)
}

func evalBlockEnd(_ content: String, type: String,
                  file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .blockEnd(TokenMeta(raw: content, lineNumber: -1), name: type),
           file: file, line: line)
}

func evalBlockBegin(_ content: String, type: String, params: [String]?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .blockBegin(TokenMeta(raw: content, lineNumber: -1), name: type, params: params),
           file: file, line: line)
}

func evalHeadline(_ content: String, level: Int, text: String?,
                    file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .headline(TokenMeta(raw: content, lineNumber: -1), level: level, text: text),
           file: file, line: line)
}

func evalSetting(_ content: String, key: String, value: String?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .setting(TokenMeta(raw: content, lineNumber: -1), key: key, value: value),
           file: file, line: line)
}

func evalBlank(_ content: String, rawIsNil: Bool = false,
                 file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .blank(TokenMeta(raw: rawIsNil ? nil : content, lineNumber: -1)),
           file: file, line: line)
}

func evalLine(_ content: String, text: String,
              file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .line(TokenMeta(raw: content, lineNumber: -1), text: text),
           file: file, line: line)
}

func evalDrawerBegin(_ content: String, name: String,
              file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .drawerBegin(TokenMeta(raw: content, lineNumber: -1), name: name),
           file: file, line: line)
}

func evalDrawerEnd(_ content: String,
                     file: StaticString = #file, line: UInt = #line) {
    let token = tokenize(line: content)
    expect(token!, toBe: .drawerEnd(TokenMeta(raw: content, lineNumber: -1)),
           file: file, line: line)
}
