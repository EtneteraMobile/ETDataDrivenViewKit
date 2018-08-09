//
//  DiffableRef.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 31. 07. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

/// `DiffableRef` bridges `DiffableType` to
/// `Differentiator.IdentifiableType & Equatable`.
///
/// - Note: There is need for this because `Differentiator.IdentifiableType & Equatable` is
///         self constrained protocol. `TableSection.items` mixes multiple types
///         therefore there couldn't be used generic.
///
/// - Important: `DiffableRef` is public, but could be used only internaly in
///         `ETDataDrivenViewKit` module.
public class DiffableRef: IdentifiableType, Equatable {
    public let value: DiffableType
    public var identity: Int { return value.identity }

    public init(_ value: DiffableType) {
        self.value = value
    }

    public static func == (lhs: DiffableRef, rhs: DiffableRef) -> Bool {
        return lhs.value.contentHash == rhs.value.contentHash
    }
}
