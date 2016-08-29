//
//  ParserTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 27/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Quick
import Nimble
import CocoaOrg

class ParserTests: QuickSpec {
    func parse(lines: [String]) -> Document? {
        let parser = Parser(tokens: Lexer(lines: lines).tokenize())
        do {
            return try parser.parse()
        } catch {
            fail("Unexpected error.")
        }
        return nil
    }
    
    override func spec() {
        describe("Parser") {
            it("parses settings") {
                let doc = self.parse([
                    "#+options: toc:nil",
                    "  ",
                    "* First Head Line",
                    ])
                expect(doc?.settings).to(haveCount(1))
                expect(doc?.settings?["options"]) == "toc:nil"
            }
            it("parses headers") {
                let doc = self.parse([
                    "* Header 1",
                    "* Header 2",
                    "  A line of content.",
                    "** Header 2.1",
                    "*** Header 2.1.1",
                    "** Header 2.2",
                    "* Header 3",
                    ])
                expect(doc?.nodes).to(haveCount(3))
                guard let h1 = doc?.nodes[0] as? Section else {
                    fail("Expect nodes[0] to be Section")
                    return
                }
                expect(h1.level) == 1
                expect(h1.title) == "Header 1"
                expect(h1.nodes).to(beEmpty())

                guard let h2 = doc?.nodes[1] as? Section else {
                    fail("Expect nodes[1] to be Section")
                    return
                }
                expect(h2.level) == 1
                expect(h2.title) == "Header 2"
                expect(h2.nodes).to(haveCount(3))
                
                guard let line = h2.nodes![0] as? Line else {
                    fail("Expect h2.nodes[0] to be Line")
                    return
                }
                expect(line.text) == "A line of content."
                
            }
            it("parses valid org file") {
                let lines = [
                    "#+options: toc:nil",
                    "  ",
                    "** Hello World",
                    "*** TODO The subsection",
                    "  This is a test.",
                    "  # This is a comment.",
                    "  #+begin_src java",
                    "  class HelloWorld {",
                    "  # print(\"Hell World\");",
                    "  }",
                    "  #+END_SRC",
                    "  #+BEGIN_QUOTE",
                    "  What doesn't kill you only makes you stronger.",
                    "  #+END_QUOTE",
                    "  #+BEGIN_QUOTE",
                    "  Endless pain.",
                    "  Yeah, endless",
                    "** Section 2",
                    "   Hello world again.",
                    ]
                let lexer = Lexer(lines: lines)
                let tokens = lexer.tokenize()
                for token in tokens {
                    print("- \(token)")
                }
                let parser = Parser(tokens: tokens)
                do {
                    let doc = try parser.parse()
                    print(doc)
                } catch let Errors.UnexpectedToken(msg) {
                    print("[ERROR] \(msg)")
                } catch {
                    print("something went wrong")
                }
            }
            
            it("does inline parses") {
                let text = "hello *world*, and /Welcome/ to *org* world. and [[http://google.com][this]] is a link. and [[/image/logo.png][this]] is a image."
//                let splitted = text.matchSplit("(\\*)([\\s\\S]*?)\\1", options: [])
                let lexer = InlineLexer(text: text)
                let tokens = lexer.tokenize()
                for t in tokens {
                    print("-- \(t)")
                }
            }
        }
    }
}