//
//  ParseBlockTests.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 17/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import XCTest
import SwiftOrg

class ParseBlockTests: XCTestCase {
    
    func testParseBlock() {
        guard let doc = parse([
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
            "#+begin_src no-end",
            " This is a normal line",
            " # print(\"Hell World\");",
            ]) else { return }
        
        XCTAssertEqual(doc.content.count, 6)
        guard let block1 = doc.content[0] as? Block else {
            XCTFail("Expect 0 to be Block")
            return
        }
        XCTAssertEqual(block1.name, "src")
        XCTAssertEqual(block1.params!, ["java"])
        XCTAssertEqual(block1.content, ["  class HelloWorld {", "  # print(\"Hell World\");", "  }"])
        guard let block2 = doc.content[1] as? Block else {
            XCTFail("Expect 1 to be Block")
            return
        }
        XCTAssertEqual(block2.name, "src")
        XCTAssertNil(block2.params)
        guard let block3 = doc.content[2] as? Block else {
            XCTFail("Expect 2 to be Block")
            return
        }
        XCTAssertEqual(block3.name, "src")
        XCTAssertEqual(block3.params!, ["yaml", "exports:", "results",  ":results",  "value", "html"])
        guard let comment = doc.content[3] as? Comment else {
            XCTFail("Expect 3 to be Comment")
            return
        }
        XCTAssertEqual(comment.text, "+begin_src java")
        
        // TODO make these assertion work
        //                expect(doc.children[4].value).to(beAnInstanceOf(Paragraph))
        //                expect(doc.children[5].value).to(beAnInstanceOf(Comment))
    }
    
}
