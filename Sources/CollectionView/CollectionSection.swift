//
//  CollectionSection.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

/// Holds data for section. Every section has rows, optionaly header and footer.
public struct CollectionSection: AnimatableSectionModelType {
    /// Identification of section for diffing algorithm.
    public let identity: String
    /// Rows content wrapped in `DiffableRef`
    public let items: [DiffableRef]
    /// Rows content that was inserted in `init`.
    /// - Attention: Getter only extracts content from `items`.
    public var rows: [DiffableType] {
        return items.map { $0.value }
    }

    /// Initializes `SectionModel` with given `identity`, `header`, `rows` and `footer`.
    public init(identity: String, rows: [DiffableType]) {
        self.identity = identity
        self.items = rows.map { DiffableRef($0) }
    }

    /// Initializes `SectionModel` with `identity` from given original and given `rows`.
    public init(original: CollectionSection, items: [DiffableRef]) {
        self.identity = original.identity
        self.items = items
        // `original` section contains old header and footer, new values will
        // be set in `TableAdapter.deliverHeaderFooterUpdate`.
    }
}

