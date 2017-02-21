@testable import SwiftOrgTests
import XCTest

XCTMain([testCase(TokenizerTests.allTests),
         testCase(IndexingTests.allTests),
         testCase(InlineParsingTests.allTests),
        ])
