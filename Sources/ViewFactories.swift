//
//  ViewFactories.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Base abstraction for view factory.
/// - Warning: Do not inherit from this class, use `AbstractFactory` or `AbstractCellFactory` instead.
open class BaseAbstractFactory {
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

    func heightInternal(for content: Any, width: CGFloat) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func setupInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }

    func willDisplayInternal(_ view: UIView, _ content: Any) {
        fatalError("Not Implemented")
    }

    func shouldHighlighInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }

    func didSelectInternal(_ content: Any, isEditing: Bool) {
        fatalError("Not Implemented")
    }
    
    func didDeselectInternal(_ content: Any, isEditing: Bool) {
        fatalError("Not Implemented")
    }

    func accessoryButtonTappedInternal(_ content: Any) {
        fatalError("Not Implemented")
    }

    // MARK: private

    private lazy var _reuseId: String = NSStringFromClass(type(of: self))
}

/// Abstract factory for view (like Header/Footer)
open class AbstractFactory<ContentType, View: UIView>: BaseAbstractFactory {
    // MARK: public

    /// Calculates height of component for given content and width.
    ///
    /// - Parameters:
    ///   - content: Content that is used for view customization.
    ///   - width: Max width of layouted component
    /// - Returns: Height of component.
    open func height(for content: ContentType, width: CGFloat) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    /// Updates given view with given content.
    /// This function is called from cellForRow.
    ///
    /// - Parameters:
    ///   - view: View that will be customized
    ///   - content: Content for customization
    open func setup(_ view: View, _ content: ContentType) {}

    /// This function is called from willDisplayCell.
    ///
    /// - Parameters:
    ///   - view: View that can be updated
    ///   - content: Content for customization
    open func willDisplay(_ view: View, _ content: ContentType) {}

    /// Determines if tableView should highligh cell with given content.
    /// Default is `true`.
    ///
    /// - Parameter content: Content of cell that should be highlighted
    /// - Returns: True – highlight is enable; False – disabled highlight
    open func shouldHighligh(_ content: ContentType) -> Bool {
        return true
    }

    /// Notifies when user press cell.
    ///
    /// - Parameter content: Content of cell
    open func didSelect(_ content: ContentType, isEditing: Bool) {}
    
    /// Notifies when user deselect cell.
    ///
    /// - Parameter content: Content of cell
    open func didDeselect(_ content: ContentType, isEditing: Bool) {}

    /// Notifies when user press accessory button of cell.
    ///
    /// - Parameter content: Content of cell
    open func accessoryButtonTapped(_ content: ContentType) {}

    // MARK: internal

    override var viewClass: AnyClass {
        return View.self
    }

    override func shouldHandleInternal(_ content: Any) -> Bool {
        return typedContent(content) != nil
    }

    override func heightInternal(for content: Any, width: CGFloat) -> CGFloat {
        return height(for: typedContent(content)!, width: width)
    }

    override func setupInternal(_ view: UIView, _ content: Any) {
        setup(typedView(view)!, typedContent(content)!)
    }

    override func willDisplayInternal(_ view: UIView, _ content: Any) {
        willDisplay(typedView(view)!, typedContent(content)!)
    }

    override func shouldHighlighInternal(_ content: Any) -> Bool {
        return shouldHighligh(typedContent(content)!)
    }

    override func didSelectInternal(_ content: Any, isEditing: Bool) {
        didSelect(typedContent(content)!, isEditing: isEditing)
    }
    
    override func didDeselectInternal(_ content: Any, isEditing: Bool) {
        didDeselect(typedContent(content)!, isEditing: isEditing)
    }

    override func accessoryButtonTappedInternal(_ content: Any) {
        accessoryButtonTapped(typedContent(content)!)
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

/// Abstract factory for cell
open class AbstractCellFactory<ContentType, View: UITableViewCell>: AbstractFactory<ContentType, View> {}
