//
//  TaskKitConfiguration.swift
//  TaskKit
//
//  Created by Aman Verma on 24/06/25.
//

import Foundation

public struct TaskKitConfiguration {
    public let identifier: String
    public let interval: TimeInterval
    
    #warning("iOS may throttle or skip background tasks scheduled too frequently. Use longer intervals for better reliability.")
    public init(identifier: String, interval: TimeInterval = 15 * 60) {
        self.identifier = identifier
        self.interval = interval
    }
}
