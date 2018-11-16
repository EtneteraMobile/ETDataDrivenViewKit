//
//  AbstractCellFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Abstract factory for cell
open class AbstractCollectionCellFactory<ContentType, View: UICollectionViewCell>: _BaseCollectionAbstractFactory {
    override var viewClass: AnyClass {
        return View.self
    }
    
    override func shouldHandleInternal(_ content: Any) -> Bool {
        return typedContent(content) != nil
    }
    
    // MARK: - CollectionView
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
    
    /// Determines if collectionView should highligh cell with given content.
    /// Default is `true`.
    ///
    /// - Parameter content: Content of cell that should be highlighted
    /// - Returns: True – highlight is enable; False – disabled highlight
    open func shouldHighligh(_ content: ContentType) -> Bool {
        return true
    }
    
    override func shouldHighlighInternal(_ content: Any) -> Bool {
        return shouldHighligh(typedContent(content)!)
    }
    
    open func didHighlight(_ content: ContentType) {}
    
    override func didHighlighInternal(_ content: Any) {
        return didHighlight(typedContent(content)!)
    }
    
    open func didUnhighlight(_ content: ContentType) {}
    
    override func didUnhighlighInternal(_ content: Any) {
        return didUnhighlight(typedContent(content)!)
    }
    
    open func shouldSelect(_ content: ContentType) -> Bool {
        return true
    }
    
    override func shouldSelectInternal(_ content: Any) -> Bool {
        return shouldSelect(typedContent(content)!)
    }
    
    open func shouldDeselect(_ content: ContentType) -> Bool {
        return true
    }
    
    override func shouldDeselectInternal(_ content: Any) -> Bool {
        return shouldDeselect(typedContent(content)!)
    }
    
    /// Notifies when user press cell.
    ///
    /// - Parameter content: Content of cell
    open func didSelect(_ content: ContentType) {}
    
    override func didSelectInternal(_ content: Any) {
        didSelect(typedContent(content)!)
    }
    
    /// Notifies when user deselect cell.
    ///
    /// - Parameter content: Content of cell
    open func didDeselect(_ content: ContentType) {}
    
    override func didDeselectInternal(_ content: Any) {
        didDeselect(typedContent(content)!)
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
    
    /// Default is .zero
    open func sizeForContent(_ content: ContentType) -> CGSize {
        return .zero
    }
    
    override func sizeForContentInternal(_ content: Any) -> CGSize {
        return sizeForContent(typedContent(content)!)
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
