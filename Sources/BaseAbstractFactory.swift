//
//  BaseAbstractFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 17. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Base abstraction for view factory.
/// - Warning: Do not inherit from this class, use `AbstractFactory` or `AbstractCellFactory` instead.
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

    // MARK: - TableView
    // MARK: DataSource

    func setupInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }
    func canEditInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }
    func canMoveInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }
    func moveInternal(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        fatalError("Not Implemented")
    }
    func commitInternal(editingStyle: UITableViewCellEditingStyle, for content: Any) {
        fatalError("Not Implemented")
    }

    // MARK: Delegate

    func willDisplayInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }

    func didEndDisplayingInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }

    func heightInternal(for content: Any, width: CGFloat) -> CGFloat {
        fatalError("Not Implemented")
    }

    func estimatedHeightInternal(for content: Any, width: CGFloat) -> CGFloat {
        fatalError("Not Implemented")
    }

    func accessoryButtonTappedInternal(_ content: Any) {
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

    func willSelectInternal(_ content: Any, _ indexPath: IndexPath, isEditing: Bool) -> IndexPath {
        fatalError("Not Implemented")
    }

    func willDeselectInternal(_ content: Any, _ indexPath: IndexPath, isEditing: Bool) -> IndexPath {
        fatalError("Not Implemented")
    }

    func didSelectInternal(_ content: Any, isEditing: Bool) {
        fatalError("Not Implemented")
    }

    func didDeselectInternal(_ content: Any, isEditing: Bool) {
        fatalError("Not Implemented")
    }

    func editingStyleInternal(_ content: Any) -> UITableViewCellEditingStyle {
        fatalError("Not Implemented")
    }

    func titleForDeleteConfirmationButtonInternal(_ content: Any) -> String? {
        fatalError("Not Implemented")
    }

    func editActionsInternal(_ content: Any) -> [UITableViewRowAction]? {
        fatalError("Not Implemented")
    }

    @available(iOSApplicationExtension 11.0, *)
    func leadingSwipeActionsConfigurationInternal(_ content: Any) -> UISwipeActionsConfiguration? {
        fatalError("Not Implemented")
    }

    @available(iOSApplicationExtension 11.0, *)
    func trailingSwipeActionsConfigurationInternal(_ content: Any) -> UISwipeActionsConfiguration? {
        fatalError("Not Implemented")
    }

    func shouldIndentWhileEditingInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }

    func willBeginEditingInternal(_ content: Any) {
        fatalError("Not Implemented")
    }

    func didEndEditingInternal(_ content: Any) {
        fatalError("Not Implemented")
    }

    func targetIndexPathForMoveInternal(from sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        fatalError("Not Implemented")
    }

    func indentationLevelInternal(_ content: Any) -> Int {
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

