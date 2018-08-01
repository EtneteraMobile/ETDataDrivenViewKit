//
//  TableSection.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

/// Holds data for section. Every section has rows, optionaly header and footer.
public struct TableSection: AnimatableSectionModelType {
    /// Identification of section for diffing algorithm.
    public let identity: String
    /// 
    public let items: [AnyContent]
    public var rows: [IdentifiableType] {
        return items.map { $0.content }
    }

    public init(identity: String, rows: [IdentifiableType]) {
        self.identity = identity
        self.items = rows.map { AnyContent($0) }
    }

    public init(original: TableSection, items: [AnyContent]) {
        self.identity = original.identity
        self.items = items
    }
}

