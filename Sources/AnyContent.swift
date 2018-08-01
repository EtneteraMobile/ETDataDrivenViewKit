//
//  AnyContent.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 31. 07. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

/// `AnyContent` bridges `ETDataDrivenViewKit.IdentifiableType` to
/// `Differentiator.IdentifiableType`.
///
/// - Note: There is need for this because `Differentiator.IdentifiableType` is
///         self constrained protocol. `TableSection.items` mixes multiple types
///         therefore there couldn't be used generic.
///
/// - Important: `AnyContent` is public, but could be used only internaly in
///         `ETDataDrivenViewKit` module.
public struct AnyContent: Differentiator.IdentifiableType, Equatable {
    public let identity: Int
    public let content: IdentifiableType

    public init(_ content: IdentifiableType) {
        self.identity = content.identity
        self.content = content
    }

    public static func == (lhs: AnyContent, rhs: AnyContent) -> Bool {
        return lhs.identity == rhs.identity
    }
}
