//
//  BaseAbstractFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 17. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Base abstraction for view factory that share code for Table and Collection.
/// - Warning: Do not inherit from this class, use `AbstractTableCellFactory`,
/// `AbstractTableHeaderFooterFactory` or `AbstractCollectionCellFactory` instead.
open class _BaseAbstractFactory {
    // MARK: public

    /// Reuse identifier used by tableView to recognize cell
    /// - Note: By default is derived from class name of `self`
    open var reuseId: String {
        return _reuseId
    }

    public init() {}

    // MARK: internal

    var viewClass: AnyClass {
        fatalError("Not Implemented")
    }

    func shouldHandleInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }

    // MARK: DataSource

    func setupInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }

    func canMoveInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }
    
    func moveInternal(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        fatalError("Not Implemented")
    }

    // MARK: Delegate

    func willDisplayInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }

    func shouldHighlighInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }

    func didHighlighInternal(_ content: Any) {
        fatalError("Not Implemented")
    }

    func didUnhighlighInternal(_ content: Any) {
        fatalError("Not Implemented")
    }

    func shouldShowMenuInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }

    func canPerformActionInternal(action: Selector, for content: Any, withSender sender: Any?) -> Bool {
        fatalError("Not Implemented")
    }

    func performActionInternal(action: Selector, for content: Any, withSender sender: Any?) {
        fatalError("Not Implemented")
    }

    // MARK: private

    private lazy var _reuseId: String = NSStringFromClass(type(of: self))
}

