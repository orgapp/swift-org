//
//  Table.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 30/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Table: Node {
    
    public struct Row {
        public var cells: [String] = []
        public var hasSeparator: Bool = false
        
        init(_ theCells: [String], hasSeparator itHasSeparator: Bool = false) {
            cells = theCells
            hasSeparator = itHasSeparator
        }
    }
    
    public var rows: [Row] = []
    
    public var description: String {
        let data = rows.map { row in
            return "\(row)"
        }.joined(separator: "\n")
        return "Table(rows:\n\(data))"
    }
}

extension OrgParser {
    func parseTable() throws -> Table {
        var table = Table()
        while let (_, token) = tokens.peek() {
            switch token {
            case .tableRow(let cells):
                _ = tokens.dequeue()
                table.rows.append(Table.Row(cells))
            case .horizontalSeparator:
                _ = tokens.dequeue()
                if !table.rows.isEmpty {
                    table.rows[table.rows.count - 1]
                        = Table.Row(table.rows.last!.cells, hasSeparator: true)
                }
            default:
                return table
            }
        }
        return table
    }
}
