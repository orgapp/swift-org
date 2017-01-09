//
//  Constants.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 9/01/17.
//  Copyright © 2017 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum PlanningKeyword: String {
    case deadline = "DEADLINE"
    case scheduled = "SCHEDULED"
    case closed = "CLOSED"
    
    static let all = [deadline.rawValue, scheduled.rawValue, closed.rawValue]
}

public enum Priority: String {
    case A = "A"
    case B = "B"
    case C = "C"
}
