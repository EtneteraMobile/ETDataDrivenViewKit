//
//  ViewFactories.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

public protocol BaseFactoryType {
    init()
    var reuseId: String { get }
    var heightDimension: HeightDimension { get }
    var viewClass: AnyClass { get }
    func shouldHandle(_ content: Any) -> Bool
}

public protocol CellFactoryType: BaseFactoryType {
    func setup(_ cell: UITableViewCell, with content: Any)
}

public protocol HeaderFooterFactoryType: BaseFactoryType {
    func setup(_ view: UIView, with content: Any)
}

// MARK: - Abstract implementation

open class AbstractFactory<InputType, ViewType: AnyObject>: BaseFactoryType {
    public required init() {}

    open var heightDimension: HeightDimension {
        return .automatic
    }

    open var reuseId: String {
        return NSStringFromClass(type(of: self))
    }

    open var viewClass: AnyClass {
        return ViewType.self
    }

    open func shouldHandle(_ content: Any) -> Bool {
        return toTypedContent(content) != nil
    }

    // MARK: Type checking

    open func toTypedContent(_ content: Any) -> InputType? {
        return content as? InputType
    }

    open func toTypedView(_ view: UIView) -> ViewType? {
        return view as? ViewType
    }
}

// MARK: Cell

open class AbstractCellFactory<InputType, ViewType: AnyObject>: AbstractFactory<InputType, ViewType>, CellFactoryType {
    open func setup(_ cell: UITableViewCell, with content: Any) {
        // Empty implementation
    }
}

// MARK: Header/Footer

open class AbstractHeaderFooterFactory<InputType, ViewType: AnyObject>: AbstractFactory<InputType, ViewType>, HeaderFooterFactoryType {
    open func setup(_ view: UIView, with content: Any) {
        // Empty implementation
    }
}
