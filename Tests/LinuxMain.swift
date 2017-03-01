@testable import SwiftOrgTests
import XCTest

XCTMain([testCase(TokenizerTests.allTests),
         testCase(IndexingTests.allTests),
         testCase(InlineParsingTests.allTests),
         testCase(ParserTests.allTests),
         testCase(TimestampTests.allTests),
         testCase(ConvertToJSONTests.allTests),
        ])
