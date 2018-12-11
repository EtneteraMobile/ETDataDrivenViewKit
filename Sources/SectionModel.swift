//
//  SectionModel.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

/// Holds data for section. Every section has rows, optionaly header and footer.
public struct SectionModel: AnimatableSectionModelType {
    /// Identification of section for diffing algorithm.
    public let identity: String
    /// Content that represents header data
    public let header: DiffableType?
    /// Rows content wrapped in `DiffableRef`
    public let items: [DiffableRef]
    /// Rows content that was inserted in `init`.
    /// - Attention: Getter only extracts content from `items`.
    public var rows: [DiffableType] {
        return items.map { $0.value }
    }
    /// Content that represents footer data
    public let footer: DiffableType?

    /// Initializes `SectionModel` with given `identity`, `header`, `rows` and `footer`.
    public init(identity: String, header: DiffableType? = nil, rows: [DiffableType], footer: DiffableType? = nil) {
        self.identity = identity
        self.header = header
        self.items = rows.map { DiffableRef($0) }
        self.footer = footer
    }

    /// Initializes `SectionModel` with `identity` from given original and given `rows`.
    public init(original: SectionModel, items: [DiffableRef]) {
        self.identity = original.identity
        self.header = original.header
        self.items = items
        self.footer = original.footer
        // `original` section contains old header and footer, new values will
        // be set in `TableAdapter.deliverHeaderFooterUpdate`.
    }
}

