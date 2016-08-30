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
    
    func makeSure(tokens: [Token], matches: [MatcherFunc<Token>]) {
        expect(tokens).to(haveCount(matches.count))
        for i in 0..<tokens.count {
            expect(tokens[i]).to(matches[i])
        }
    }
    
    func tokenize(lines: [String]) -> [Token] {
        return Lexer(lines: lines).tokenize()
    }
    override func spec() {
        describe("Lexer") {
            it("tokenize blank") {
                let tokens = self.tokenize([
                    "",
                    " ",
                    "\t",
                    "  \t  ",
                    ])
                expect(tokens).to(allPass(beBlank()))
            }
            it("tokenize setting") {
                let tokens = self.tokenize([
                    "#+options: toc:nil",
                    "#+options:    toc:nil",
                ])
                expect(tokens).to(allPass(beSetting("options", value: "toc:nil")))
            }
            it("tokenize header") {
                let tokens = self.tokenize([
                    "* Level One",
                    "** Level Two",
                    "* TODO Level One with todo",
                    "* ",
                    "*",
                    " * ",
                ])
                self.makeSure(tokens, matches: [
                    beHeader(1, text: "Level One", state: nil),
                    beHeader(2, text: "Level Two", state: nil),
                    beHeader(1, text: "Level One with todo", state: "TODO"),
                    beHeader(1, text: nil, state: nil),
                    beLine("*"),
                    beLine("* "),
                    ])
            }
            it("tokenize src block") {
                let tokens = self.tokenize([
                    "#+begin_src java",
                    "  class HelloWorld {",
                    "  # print(\"Hell World\");",
                    "  }",
                    "#+END_SRC",
                    "  #+begin_src",
                    "  #+end_src",
                    "  #+begin_src yaml exports: results :results value html",
                    "#+END_SRC",
                    "# +begin_src java",
                    ])
                expect(tokens).to(matcheAll([
                    beBlockBegin("src", params: ["java"]),
                    beRaw("  class HelloWorld {"),
                    beRaw("  # print(\"Hell World\");"),
                    beRaw("  }"),
                    beBlockEnd("SRC"),
                    beBlockBegin("src", params: nil),
                    beBlockEnd("src"),
                    beBlockBegin("src", params: ["yaml", "exports:", "results", ":results", "value", "html"]),
                    beBlockEnd("SRC"),
                    beComment("+begin_src java"),
                    ]))
            }
            it("tokenize broken block") {
                let tokens = self.tokenize([
                    "#+BEGIN_QUOTE",
                    "#+begin_src java",
                    "  class HelloWorld {",
                    "  }",
                    ])
                expect(tokens).to(matcheAll([
                    beLine("#+BEGIN_QUOTE"),
                    beLine("#+begin_src java"),
                    beLine("class HelloWorld {"),
                    beLine("}"),
                    ]))
            }
            it("tokenize comment") {
                let tokens = self.tokenize([
                    "# a line of comment",
                    "#    a line of comment",
                    "#not comment",
                    ])
                expect(tokens).to(matcheAll([
                    beComment("a line of comment"),
                    beComment("a line of comment"),
                    beLine("#not comment"),
                    ]))
            }
            it("tokenize horizontal rule") {
                let tokens = self.tokenize([
                    "-----",
                    "----------",
                    "  -----",
                ])
                expect(tokens).to(allPass(beHorizontalRule()))
                
                let lines = self.tokenize([
                    "----"
                    ])
                expect(lines).to(allPass(beLine("----")))
            }
            it("tokenize line") {
            }
        }
    }
}
