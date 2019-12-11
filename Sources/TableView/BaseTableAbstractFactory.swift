//
//  ViewFactories.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Abstract factory for view (like Header/Footer)
open class BaseTableAbstractFactory<ContentType, View: UIView>: _BaseTableAbstractFactory {
    override var viewClass: AnyClass {
        return View.self
    }

    override func shouldHandleInternal(_ content: Any) -> Bool {
        return typedContent(content) != nil
    }

    // MARK: - TableView
    // MARK: DataSource

    /// Updates given view with given content.
    /// This function is called from cellForRow.
    ///
    /// - Parameters:
    ///   - view: View that will be customized
    ///   - content: Content for customization
    open func setup(_ view: View, _ content: ContentType) {}

    override func setupInternal(_ view: UIView, _ content: Any) {
        setup(typedView(view)!, typedContent(content)!)
    }

    /// Default is true
    open func canEdit(_ content: ContentType) -> Bool {
        return true
    }

    override func canEditInternal(_ content: Any) -> Bool {
        return canEdit(typedContent(content)!)
    }

    /// Defaults is false
    open func canMove(_ content: ContentType) -> Bool {
        return false
    }

    override func canMoveInternal(_ content: Any) -> Bool {
        return canMove(typedContent(content)!)
    }

    open func move(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {}

    override func moveInternal(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        move(from: sourceIndexPath, to: destinationIndexPath)
    }

    open func commit(editingStyle: UITableViewCell.EditingStyle, for content: ContentType) {}

    override func commitInternal(editingStyle: UITableViewCell.EditingStyle, for content: Any) {
        commit(editingStyle: editingStyle, for: typedContent(content)!)
    }

    // MARK: Delegate

    /// This function is called from willDisplayCell.
    ///
    /// - Parameters:
    ///   - view: View that can be updated
    ///   - content: Content for customization
    open func willDisplay(_ view: View, _ content: ContentType) {}

    override func willDisplayInternal(_ view: UIView, _ content: Any) {
        willDisplay(typedView(view)!, typedContent(content)!)
    }

    /// Calculates height of component for given content and width.
    /// Default is UITableViewAutomaticDimension
    ///
    /// - Parameters:
    ///   - content: Content that is used for view customization.
    ///   - width: Max width of layouted component
    /// - Returns: Height of component.
    open func height(for content: ContentType, width: CGFloat) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func heightInternal(for content: Any, width: CGFloat) -> CGFloat {
        return height(for: typedContent(content)!, width: width)
    }

    /// Notifies when user press accessory button of cell.
    ///
    /// - Parameter content: Content of cell
    open func accessoryButtonTapped(_ content: ContentType) {}

    override func accessoryButtonTappedInternal(_ content: Any) {
        accessoryButtonTapped(typedContent(content)!)
    }

    /// Determines if tableView should highligh cell with given content.
    /// Default is `true`.
    ///
    /// - Parameter content: Content of cell that should be highlighted
    /// - Returns: True – highlight is enable; False – disabled highlight
    open func shouldHighlight(_ content: ContentType) -> Bool {
        return true
    }

    override func shouldHighlighInternal(_ content: Any) -> Bool {
        return shouldHighlight(typedContent(content)!)
    }

    open func didHighlight(_ content: ContentType) {}

    override func didHighlighInternal(_ content: Any) {
        return didHighlight(typedContent(content)!)
    }

    open func didUnhighlight(_ content: ContentType) {}

    override func didUnhighlighInternal(_ content: Any) {
        return didUnhighlight(typedContent(content)!)
    }

    open func willSelect(_ content: ContentType, _ indexPath: IndexPath, isEditing: Bool) -> IndexPath {
        return indexPath
    }

    override func willSelectInternal(_ content: Any, _ indexPath: IndexPath, isEditing: Bool) -> IndexPath {
        return willSelect(typedContent(content)!, indexPath, isEditing: isEditing)
    }

    open func willDeselect(_ content: ContentType, _ indexPath: IndexPath, isEditing: Bool) -> IndexPath {
        return indexPath
    }

    override func willDeselectInternal(_ content: Any, _ indexPath: IndexPath, isEditing: Bool) -> IndexPath {
        return willDeselect(typedContent(content)!, indexPath, isEditing: isEditing)
    }

    /// Notifies when user press cell.
    ///
    /// - Parameter content: Content of cell
    open func didSelect(_ content: ContentType, isEditing: Bool) {}

    override func didSelectInternal(_ content: Any, isEditing: Bool) {
        didSelect(typedContent(content)!, isEditing: isEditing)
    }

    /// Notifies when user deselect cell.
    ///
    /// - Parameter content: Content of cell
    open func didDeselect(_ content: ContentType, isEditing: Bool) {}

    override func didDeselectInternal(_ content: Any, isEditing: Bool) {
        didDeselect(typedContent(content)!, isEditing: isEditing)
    }

    /// Default is none
    open func editingStyle(_ content: ContentType) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func editingStyleInternal(_ content: Any) -> UITableViewCell.EditingStyle {
        return editingStyle(typedContent(content)!)
    }

    /// Default is nil
    open func titleForDeleteConfirmationButton(_ content: ContentType) -> String? {
        return "Localize me"
    }

    override func titleForDeleteConfirmationButtonInternal(_ content: Any) -> String? {
        return titleForDeleteConfirmationButton(typedContent(content)!)
    }

    /// Defaults is nil
    open func editActions(_ content: ContentType) -> [UITableViewRowAction]? {
        return nil
    }

    override func editActionsInternal(_ content: Any) -> [UITableViewRowAction]? {
        return editActions(typedContent(content)!)
    }

    /// Default is nil
    @available(iOSApplicationExtension 11.0, iOS 11.0, *)
    open func leadingSwipeActionsConfiguration(_ content: ContentType) -> UISwipeActionsConfiguration? {
        return nil
    }

    @available(iOSApplicationExtension 11.0, iOS 11.0, *)
    override func leadingSwipeActionsConfigurationInternal(_ content: Any) -> UISwipeActionsConfiguration? {
        return leadingSwipeActionsConfiguration(typedContent(content)!)
    }

    /// Defaults is nil
    @available(iOSApplicationExtension 11.0, iOS 11.0, *)
    open func trailingSwipeActionsConfiguration(_ content: ContentType) -> UISwipeActionsConfiguration? {
        return nil
    }

    @available(iOSApplicationExtension 11.0, iOS 11.0, *)
    override func trailingSwipeActionsConfigurationInternal(_ content: Any) -> UISwipeActionsConfiguration? {
        return trailingSwipeActionsConfiguration(typedContent(content)!)
    }

    /// Defaults is true
    open func shouldIndentWhileEditing(_ content: ContentType) -> Bool {
        return true
    }

    override func shouldIndentWhileEditingInternal(_ content: Any) -> Bool {
        return shouldIndentWhileEditing(typedContent(content)!)
    }

    open func willBeginEditing(_ content: ContentType) {}

    override func willBeginEditingInternal(_ content: Any) {
        willBeginEditing(typedContent(content)!)
    }

    open func didEndEditing(_ content: ContentType) {}

    override func didEndEditingInternal(_ content: Any) {
        didEndEditing(typedContent(content)!)
    }

    /// Default is `toProposedIndexPath`
    open func targetIndexPathForMove(from sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }

    override func targetIndexPathForMoveInternal(from sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return targetIndexPathForMove(from: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
    }

    /// Default is 0
    open func indentationLevel(_ content: ContentType) -> Int {
        return 0
    }

    override func indentationLevelInternal(_ content: Any) -> Int {
        return indentationLevel(typedContent(content)!)
    }

    /// Default is false
    open func shouldShowMenu(_ content: ContentType) -> Bool {
        return false
    }

    override func shouldShowMenuInternal(_ content: Any) -> Bool {
        return shouldShowMenu(typedContent(content)!)
    }

    /// Default is false
    open func canPerformAction(action: Selector, for content: ContentType, withSender sender: Any?) -> Bool {
        return false
    }

    override func canPerformActionInternal(action: Selector, for content: Any, withSender sender: Any?) -> Bool {
        return canPerformAction(action: action, for: typedContent(content)!, withSender: sender)
    }

    open func performAction(action: Selector, for content: ContentType, withSender sender: Any?) {}

    override func performActionInternal(action: Selector, for content: Any, withSender sender: Any?) {
        performAction(action: action, for: typedContent(content)!, withSender: sender)
    }

    // MARK: private

    func typedView(_ view: UIView) -> View? {
        // Possible performance issue with casting
        return view as? View
    }

    func typedContent(_ content: Any) -> ContentType? {
        // Possible performance issue with casting
        return content as? ContentType
    }
}
