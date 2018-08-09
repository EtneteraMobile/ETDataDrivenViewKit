//
//  DiffableType.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 01. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation

public protocol DiffableType {
    /// Identify
    var identity: Int { get }
    /// Hash representation of values contained in instance
    var contentHash: Int { get }
}

public typealias DiffableHashableType = DiffableType & Hashable

public extension DiffableType where Self: Hashable {
    var contentHash: Int {
        return hashValue
    }
}
