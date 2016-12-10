//
//  OrgFileWriter.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 29/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

protocol Textifiable {
    func textify(indent: Int) -> [String]
}

extension Section: Textifiable {
    func textify(indent: Int) -> [String] {
        var lines = [String]()
        var headlineComponents = [String]()
        headlineComponents.append(String(repeating: "*", count: stars))
        if let k = keyword {
            headlineComponents.append(k)
        }
        if let p = priority {
            headlineComponents.append("[#\(p)]")
        }
        if let t = title {
            headlineComponents.append(t)
        }
        lines += [headlineComponents.joined(separator: " ")]
        
        // write drawers
        
        for d in drawers ?? [] {
            lines += d.textify(indent: stars + 1)
        }
        
        for n in content {
            if let tn = n as? Textifiable {
                lines += tn.textify(indent: stars + 1)
            }
        }
        lines += ["\n"]
        return lines
    }
}

extension Paragraph: Textifiable {
    func textify(indent: Int) -> [String] {
        return lines.map { line in line.indent(indent) }
    }
}

extension Block: Textifiable {
    func textify(indent: Int) -> [String] {
        var begin = ["#+BEGIN_\(name.uppercased())"]
        if let p = params {
            begin += p
        }
        var lines = [begin.joined(separator: " ").indent(indent)]
        lines += content
        lines += ["#+END_\(name.uppercased())".indent(indent)]
        return lines
    }
}

extension List: Textifiable {
    func textify(indent: Int) -> [String] {
        // TODO impl sublist for Textifiable
        
        return items.enumerated().map { index, item in
            var parts = [ordered ? "\(index)." : "-"]
            if let c = item.checked {
                parts += [c ? "[X]" : "[ ]"]
            }
            parts += [item.text ?? ""]
            return parts.joined(separator: " ").indent(indent)
        }
    }
}

extension HorizontalRule: Textifiable {
    func textify(indent: Int) -> [String] {
        return ["-----"]
    }
}

extension Comment: Textifiable {
    func textify(indent: Int) -> [String] {
        return ["# \(text ?? "")"]
    }
}

extension Footnote: Textifiable {
    func textify(indent: Int) -> [String] {
        // TODO impl footnote for Textifiable
        return []
    }
}

extension Drawer: Textifiable {
    func textify(indent: Int) -> [String] {
        var lines = [":\(name.uppercased()):"]
        lines += content
        lines += [":END:"]
        return lines.map { line in line.indent(indent) }
    }
}

extension OrgDocument: Textifiable {
    
    func textify(indent: Int = 0) -> [String] {
        var lines = [String]()
        let settingLines = settings.map { k, v in "#+\(k): \(v)" }
        lines.append(contentsOf: settingLines)
        
        for node in content {
            if let n = node as? Textifiable {
                lines += n.textify(indent: indent)
            }
        }
        return lines
    }
    
    public func toText() -> String {
        return self.textify().joined(separator: "\n")
    }
}
