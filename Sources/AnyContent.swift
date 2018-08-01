//
//  AnyContent.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 31. 07. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

/// `AnyContent` wraps generic content into non-generic one (Any)
/// - Note: `AnyContent` is public, but could be used only internaly in `ETDataDrivenViewKit` module.
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
