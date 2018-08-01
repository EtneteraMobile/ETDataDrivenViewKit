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
    public typealias HeaderType = Any
    public typealias FooterType = Any

    /// Identification of section for diffing algorithm.
    public let identity: String
    /// 
    public let header: HeaderType?
    public let items: [AnyContent]
    public var rows: [IdentifiableType] {
        return items.map { $0.content }
    }
    public let footer: FooterType?


    public init(identity: String, rows: [IdentifiableType]) {
        self.identity = identity
        self.header = nil
        self.items = rows.map { AnyContent($0) }
        self.footer = nil
    }

    public init(identity: String, header: HeaderType, rows: [IdentifiableType]) {
        self.identity = identity
        self.header = header
        self.items = rows.map { AnyContent($0) }
        self.footer = nil
    }

    public init(identity: String, rows: [IdentifiableType], footer: FooterType) {
        self.identity = identity
        self.header = nil
        self.items = rows.map { AnyContent($0) }
        self.footer = footer
    }

    public init(identity: String, header: HeaderType, rows: [IdentifiableType], footer: FooterType) {
        self.identity = identity
        self.header = header
        self.items = rows.map { AnyContent($0) }
        self.footer = footer
    }

    public init(original: TableSection, items: [AnyContent]) {
        self.identity = original.identity
        self.header = original.header
        self.items = items
        self.footer = original.footer
    }
}

