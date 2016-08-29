//
//  CocoaOrgTests.swift
//  CocoaOrgTests
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Quick
import Nimble
import CocoaOrg

class LexerTests: QuickSpec {
    
    func check(lines: [(String, MatcherFunc<Token>)]) {
        let tokens = Lexer(lines: lines.map { $0.0 }).tokenize()
        expect(tokens).to(haveCount(lines.count))
        for i in 0..<lines.count {
            expect(tokens[i]).to(lines[i].1)
        }
    }
    
    override func spec() {
        describe("Lexer") {
            it("tokenize blank") {
                self.check([
                    ("",        beBlank()),
                    ("  ",      beBlank()),
                    ("\t",      beBlank()),
                    ("  \t  ",  beBlank()),
                    ])
            }
            it("tokenize setting") {
                self.check([
                    ("#+options: toc:nil",      beSetting("options", value: "toc:nil")),
                    ("#+options:    toc:nil",   beSetting("options", value: "toc:nil")),
                    ])
            }
            it("tokenize header") {
                self.check([
                    ("* Level One",                 beHeader(1, text: "Level One", state: nil)),
                    ("** Level Two",                beHeader(2, text: "Level Two", state: nil)),
                    ("* TODO Level One with todo",  beHeader(1, text: "Level One with todo", state: "TODO")),
                    ("* ",                          beHeader(1, text: nil, state: nil)),
                    ("*",                           beLine("*")),
                    (" * ",                         beLine("* ")),
                    ])
            }
            it("tokenize src block") {
                self.check([
                    ("#+begin_src java",            beBlockBegin("src", params: ["java"])),
                    ("  class HelloWorld {",        beRaw("  class HelloWorld {")),
                    ("  # print(\"Hell World\");",  beRaw("  # print(\"Hell World\");")),
                    ("  }",                         beRaw("  }")),
                    ("#+END_SRC",                   beBlockEnd("SRC")),
                    ("  #+begin_src",               beBlockBegin("src", params: nil)),
                    ("  #+end_src",                 beBlockEnd("src")),
                    ("  #+begin_src yaml exports: results :results value html",
                        beBlockBegin("src", params: ["yaml", "exports:", "results", ":results", "value", "html"])),
                    ("#+END_SRC",                   beBlockEnd("SRC")),
                    ("# +begin_src java",           beComment("+begin_src java")),
                    ])
            }
            it("tokenize broken block") {
                self.check([
                    ("#+BEGIN_QUOTE",           beLine("#+BEGIN_QUOTE")),
                    ("#+begin_src java",        beLine("#+begin_src java")),
                    ("  class HelloWorld {",    beLine("class HelloWorld {")),
                    ("  }",                     beLine("}")),
                    ])
            }
            it("tokenize comment") {
                self.check([
                    ("# a line of comment",     beComment("a line of comment")),
                    ("#    a line of comment",  beComment("a line of comment")),
                    ("#not comment",            beLine("#not comment")),
                    ])
            }
            it("tokenize horizontal rule") {
                self.check([
                    ("-----",       beHorizontalRule()),
                    ("----------",  beHorizontalRule()),
                    ("  -----",     beHorizontalRule()),
                    ("----",        beLine("----")),
                    ])
            }
            it("tokenize line") {
                
            }
        }
    }
}
