//
//  DiffableType.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 01. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation

/// A type that can be compared for **identity** and **value** equality.
///
/// Types that conform to the `DiffableType` protocol can be compared for
/// - **identity equality** using the equal-to operator (`==`) with `identity`
///     variable
/// - **value equality** using the equal-to operator (`==`) with `value`
///     variable
///
/// Value Equality is Separate From Identity
/// ----------------------------------------
///
/// The identity of a class instance is not part of an instance's value.
/// Consider a model called `Message`. Here's the definition for `Message` and
/// implementation that makes it conform to `DiffableType`:
///
///     class Message: DiffableType {
///         let id: String
///         let lastUpdated: Date
///         let body: String
///
///         var identity: Int { return id.hashValue }
///         var value: Int { return lastUpdated.hashValue ^ body.hashValue }
///     }
///
/// Identity is compared using the `identity` that is defined by hashValue of
/// `id` property.
///
/// Value equality, on the other hand, is compared using the `value` that
/// returns same value for same `lastUpdated` and `body` and can return the same
/// value although `id` is different.
public protocol DiffableType {
    /// Identity of values contained in instance
    var identity: Int { get }
    /// Hash representation of values contained in instance
    var value: Int { get }
}

public typealias DiffableHashableType = DiffableType & Hashable

public extension DiffableType where Self: Hashable {
    var value: Int {
        return hashValue
    }
}

/// Compares `identity` of given arguments.
///
/// - Parameters:
///   - lhs: Left hand argument
///   - rhs: Right hand argument
/// - Returns: `true` if both arguments are nil or `identity` equals
///            otherwise return `false`
public func ===(_ lhs: DiffableType?, _ rhs: DiffableType?) -> Bool {
    if case .none = lhs, case .none = rhs {
        return true
    } else if let lhs = lhs, let rhs = rhs {
        return lhs.identity == rhs.identity
    } else {
        return false
    }
}

/// Compares `value` of given arguments.
///
/// - Parameters:
///   - lhs: Left hand argument
///   - rhs: Right hand argument
/// - Returns: `true` if both arguments are nil or `value` equals
///            otherwise return `false`
public func ==(_ lhs: DiffableType?, _ rhs: DiffableType?) -> Bool {
    if case .none = lhs, case .none = rhs {
        return true
    } else if let lhs = lhs, let rhs = rhs {
        return lhs.value == rhs.value
    } else {
        return false
    }
}
