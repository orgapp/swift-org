//
//  CocoaOrgTests.swift
//  CocoaOrgTests
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Quick
import Nimble
@testable import CocoaOrg

class LexerTests: QuickSpec {
    
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
                var tokens = self.tokenize([
                    "* Level One",
                    "** Level Two",
                    "* TODO Level One with todo",
                    "* ",
                    "*",
                    " * ",
                ]).toQueue()
                
                expect(tokens.dequeue()).to(beHeader(1, text: "Level One"))
                expect(tokens.dequeue()).to(beHeader(2, text: "Level Two"))
                expect(tokens.dequeue()).to(beHeader(1, text: "TODO Level One with todo"))
                expect(tokens.dequeue()).to(beHeader(1, text: nil))
                expect(tokens.dequeue()).to(beLine("*"))
                expect(tokens.dequeue()).to(beLine("* "))
            }
            it("tokenize src block") {
                var tokens = self.tokenize([
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
                    ]).toQueue()
                
                expect(tokens.dequeue()).to(beBlockBegin("src", params: ["java"]))
                expect(tokens.dequeue()).to(beRaw("  class HelloWorld {"))
                expect(tokens.dequeue()).to(beRaw("  # print(\"Hell World\");"))
                expect(tokens.dequeue()).to(beRaw("  }"))
                expect(tokens.dequeue()).to(beBlockEnd("SRC"))
                expect(tokens.dequeue()).to(beBlockBegin("src", params: nil))
                expect(tokens.dequeue()).to(beBlockEnd("src"))
                expect(tokens.dequeue()).to(beBlockBegin("src", params: ["yaml", "exports:", "results", ":results", "value", "html"]))
                expect(tokens.dequeue()).to(beBlockEnd("SRC"))
                expect(tokens.dequeue()).to(beComment("+begin_src java"))
                }
            it("tokenize broken block") {
                var tokens = self.tokenize([
                    "#+BEGIN_QUOTE",
                    "#+begin_src java",
                    "  class HelloWorld {",
                    "  }",
                    ]).toQueue()
                expect(tokens.dequeue()).to(beLine("#+BEGIN_QUOTE"))
                expect(tokens.dequeue()).to(beLine("#+begin_src java"))
                expect(tokens.dequeue()).to(beLine("class HelloWorld {"))
                expect(tokens.dequeue()).to(beLine("}"))
            }
            it("tokenize comment") {
                var tokens = self.tokenize([
                    "# a line of comment",
                    "#    a line of comment",
                    "#not comment",
                    ]).toQueue()
                expect(tokens.dequeue()).to(beComment("a line of comment"))
                expect(tokens.dequeue()).to(beComment("a line of comment"))
                expect(tokens.dequeue()).to(beLine("#not comment"))
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
