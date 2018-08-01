//
//  IdentifiableType.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 01. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation

/// Identify current object for diffing algorithm.
public protocol IdentifiableType {
    var identity: Int { get }
}

/// Identify current object for diffing algorithm with hashValue.
public typealias AutoIdentifiableType = IdentifiableType & Hashable
public extension IdentifiableType where Self: Hashable {
    var identity: Int {
        return hashValue
    }
}
