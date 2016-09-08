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
    func parse(lines: [String]) -> OrgNode? {
        let parser = Parser(lines: lines)
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
                guard let doc = self.parse([
                    "#+options: toc:nil",
                    "  ",
                    "* First Head Line",
                    ]) else { return }
                guard let d = doc.lookUp(DocumentMeta) else {
                    fail("Cannot find Document root.")
                    return
                }
                expect(d.settings).to(haveCount(1))
                expect(d.settings["options"]) == "toc:nil"
            }
            it("parses headers") {
                guard let doc = self.parse([
                    "#+TODO: NEXT",
                    "* Header 1",
                    "* TODO Header 2",
                    "  A line of content.",
                    "** Header 2.1",
                    "*** Header 2.1.1",
                    "** Header 2.2",
                    "* NEXT Customized todo",
                    "* "
                    ]) else { return }
                expect(doc.children).to(haveCount(4))
                print(doc)
                
                let h1Section = doc.children[0]
                guard let h1 = h1Section.value as? Section else {
                    fail("Expect nodes[0] to be Section")
                    return
                }
                expect(h1.level) == 1
                expect(h1.title) == "Header 1"
                expect(h1Section.children).to(beEmpty())

                let h2Section = doc.children[1]
                guard let h2 = h2Section.value as? Section else {
                    fail("Expect nodes[1] to be Section")
                    return
                }
                expect(h2.level) == 1
                expect(h2.title) == "Header 2"
                expect(h2.state) == "TODO"
                expect(h2Section.children).to(haveCount(3))
                
                guard let line = h2Section.children[0].value as? Paragraph else {
                    fail("Expect h2.nodes[0] to be Line")
                    return
                }
                expect(line.text) == "A line of content."
                
                let h3Section = doc.children[2]
                guard let h3 = h3Section.value as? Section else {
                    fail("Expect nodes[1] to be Section")
                    return
                }
                expect(h3.title) == "Customized todo"
                expect(h3.state) == "NEXT"
                
                let h4Section = doc.children[3]
                guard let h4 = h4Section.value as? Section else {
                    fail("Expect nodes[1] to be Section")
                    return
                }
                expect(h4.title).to(beNil())
                expect(h4.state).to(beNil())
            }
            it("parses paragraphes") {
                let lines = [
                    "Line one.",
                    "Line two.",
                    "Line three.",
                    "",
                    "Line four.",
                    "Line five.",
                    ]
                let doc = self.parse(lines)
                guard let para1 = doc?.children[0].value as? Paragraph else {
                    fail("Expect 0 to be Paragraph")
                    return
                }
                expect(para1.lines).to(haveCount(3))
                expect(para1.lines).to(contain(["Line one.", "Line two.", "Line three."]))
                
                guard let para2 = doc?.children[2].value as? Paragraph else {
                    fail("Expect 0 to be Paragraph")
                    return
                }
                expect(para2.lines).to(haveCount(2))
                expect(para2.lines).to(contain(["Line four.", "Line five."]))
                print(doc)
            }
            it("parses valid org file") {
                let lines = [
                    "#+options: toc:nil",
                    "#+title: hello world",
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
                let parser = Parser(tokens: tokens)
                do {
                    let doc = try parser.parse()
                    print("++++++++++++++++++++++++")
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