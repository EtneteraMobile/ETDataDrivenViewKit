//
//  TableSection.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation

/// Holds data for section. Every section has rows, optionaly header and footer.
public struct TableSection {
    public typealias HeaderContent = Any
    public typealias RowContent = Any
    public typealias FooterContent = Any

    let header: HeaderContent?
    let rows: [RowContent]
    let footer: FooterContent?

    public init(rows: [RowContent]) {
        self.header = nil
        self.rows = rows
        self.footer = nil
    }

    public init(header: HeaderContent, rows: [RowContent]) {
        self.header = header
        self.rows = rows
        self.footer = nil
    }

    public init(rows: [RowContent], footer: FooterContent) {
        self.header = nil
        self.rows = rows
        self.footer = footer
    }

    public init(header: HeaderContent, rows: [RowContent], footer: FooterContent) {
        self.header = header
        self.rows = rows
        self.footer = footer
    }
}
