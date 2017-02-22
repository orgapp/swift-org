extension TokenizerTests {
    static var allTests = [
      ("testTokenBlank", testTokenBlank),
      ("testTokenSetting", testTokenSetting),
      ("testTokenHeading", testTokenHeading),
      ("testTokenPlanning", testTokenPlanning),
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

// extension LexerTests {
//     static var allTests = []
// }

extension ParserTests {
    static var allTests = [
      ("testParseSettings", testParseSettings),
      ("testDefaultTodos", testDefaultTodos),
      ("testInBufferTodos", testInBufferTodos),
      ("testParseHeadline", testParseHeadline),
      ("testParseDrawer", testParseDrawer),
      ("testMalfunctionDrawer", testMalfunctionDrawer),
      ("testPriority", testPriority),
      ("testTags", testTags),
      ("testPlanning", testPlanning),
      ("testParseBlock", testParseBlock),
      ("testParseList", testParseList),
      ("testListItemWithCheckbox", testListItemWithCheckbox),
      ("testParseParagraph", testParseParagraph),
      ("testParseTable", testParseTable),
      ("testOnelineFootnote", testOnelineFootnote),
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

extension TimestampTests {
    static var allTests = [
      ("testParseTimestamp", testParseTimestamp),
      ("testTimestampWithSpacing", testTimestampWithSpacing),
      ("testTimestampWithRepeater", testTimestampWithRepeater),
      ("testTimestampWithInvalidRepeater", testTimestampWithInvalidRepeater),
      ("testInvalidTimestamp", testInvalidTimestamp),
    ]
}
