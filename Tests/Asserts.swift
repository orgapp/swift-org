//
//  Asserts.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 15/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
@testable import SwiftOrg

func expect(_ actual: Token, toBe expected: Token,
            file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expected, actual,
                   file: file, line: line)
}


func evalListItem(_ str: String, indent: Int, text: String?, ordered: Bool, checked: Bool? = nil,
          file: StaticString = #file, line: UInt = #line) {
    
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .listItem(indent: indent, text: text, ordered: ordered, checked: checked),
           file: file, line: line)
}

func evalHorizontalRule(_ str: String,
                        file: StaticString = #file, line: UInt = #line) {
        let token = Lexer.tokenize(line: str)
        expect(token!, toBe: .horizontalRule,
               file: file, line: line)
}

func evalComment(_ str: String, text: String,
                        file: StaticString = #file, line: UInt = #line) {
        let token = Lexer.tokenize(line: str)
        expect(token!, toBe: .comment(text),
               file: file, line: line)
}

func evalBlockEnd(_ str: String, type: String,
                  file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .blockEnd(name: type),
           file: file, line: line)
}

func evalBlockBegin(_ str: String, type: String, params: [String]?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .blockBegin(name: type, params: params),
           file: file, line: line)
}

func evalHeadline(_ str: String, stars: Int, text: String?,
                    file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .headline(stars: stars, text: text),
           file: file, line: line)
}

func evalPlanning(_ str: String, keyword: String, timestamp: Date,
                  file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    print(token)
}

func evalSetting(_ str: String, key: String, value: String?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .setting(key: key, value: value),
           file: file, line: line)
}

func evalBlank(_ str: String, rawIsNil: Bool = false,
                 file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .blank,
           file: file, line: line)
}

func evalLine(_ str: String, text: String,
              file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .line(text: text),
           file: file, line: line)
}

func evalDrawerBegin(_ str: String, name: String,
              file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .drawerBegin(name: name),
           file: file, line: line)
}

func evalDrawerEnd(_ str: String,
                     file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .drawerEnd,
           file: file, line: line)
}

func evalFootnote(_ str: String, label: String, content: String?,
                  file: StaticString = #file, line: UInt = #line) {
    let token = Lexer.tokenize(line: str)
    expect(token!, toBe: .footnote(label: label, content: content),
           file: file, line: line)
}
