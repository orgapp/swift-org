#if os(Linux)
extension TokenizerTests {
    static var allTests = [
      ("testTokenBlank", testTokenBlank),
      ("testTokenSetting", testTokenSetting),
      ("testTokenHeading", testTokenHeading),
      //("testTokenPlanning", testTokenPlanning), // TODO fix this
      ("testTokenBlockBegin", testTokenBlockBegin),
      ("testTokenBlockEnd", testTokenBlockEnd),
      ("testTokenComment", testTokenComment),
      ("testTokenHorizontalRule", testTokenHorizontalRule),
      ("testTokenListItem", testTokenListItem),
      ("testDrawer", testDrawer),
      ("testFootnote", testFootnote),
      ("testTable", testTable),
    ]
}

extension IndexingTests {
    static var allTests = [
      ("testIndexing", testIndexing),
      ("testSectionIndexing", testSectionIndexing),
    ]
}

extension InlineParsingTests {
    static var allTests = [
      ("testInlineParsing", testInlineParsing),
      ("testCornerCases", testCornerCases),
      ("testInlineFootnote", testInlineFootnote),
    ]
}

#endif
