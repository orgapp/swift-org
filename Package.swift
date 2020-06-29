// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftOrg",
  products: [
    .library(
      name: "SwiftOrg",
      targets: ["SwiftOrg"])
  ],
  targets: [
    .target(
      name: "SwiftOrg",
      path: "Sources",
      sources: [
        "Regex.swift",
        "Tokens.swift",
        "String.swift",
        "Timestamp.swift",
        "Table.swift",
        "SwiftOrg.h",
        "Section.swift",
        "Queue.swift",
        "Paragraph.swift",
        "OrgParser.swift",
        "OrgFileWriter.swift",
        "OrgDocument.swift",
        "Node.swift",
        "List.swift",
        "Lexer.swift",
        "Inline.swift",
        "HorizontalRule.swift",
        "Footnote.swift",
        "Drawer.swift",
        "Data.swift",
        "ConvertToJSON.swift",
        "Constants.swift",
        "Comment.swift",
        "Block.swift",
      ],
      resources: [
        .copy("Info-iOS.plist"),
        .copy("Info-macOS.plist"),
      ]
    ),
    .testTarget(
      name: "SwiftOrgTests",
      dependencies: ["SwiftOrg"]),
  ]
)
