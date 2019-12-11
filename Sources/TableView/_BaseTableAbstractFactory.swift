//
//  _BaseTableAbstractFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Base abstraction for Table factory.
/// - Warning: Do not inherit from this class, use `AbstractTableCellFactory`,
/// `AbstractTableHeaderFooterFactory` instead.
open class _BaseTableAbstractFactory: _BaseAbstractFactory {
    
    func canEditInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }
    
    func commitInternal(editingStyle: UITableViewCell.EditingStyle, for content: Any) {
        fatalError("Not Implemented")
    }
    
    func heightInternal(for content: Any, width: CGFloat) -> CGFloat {
        fatalError("Not Implemented")
    }
    
    func accessoryButtonTappedInternal(_ content: Any) {
        fatalError("Not Implemented")
    }
    
    func shouldIndentWhileEditingInternal(_ content: Any) -> Bool {
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
    
    func editingStyleInternal(_ content: Any) -> UITableViewCell.EditingStyle {
        fatalError("Not Implemented")
    }
    
    func titleForDeleteConfirmationButtonInternal(_ content: Any) -> String? {
        fatalError("Not Implemented")
    }
    
    func editActionsInternal(_ content: Any) -> [UITableViewRowAction]? {
        fatalError("Not Implemented")
    }
    
    @available(iOSApplicationExtension 11.0, iOS 11.0, *)
    func leadingSwipeActionsConfigurationInternal(_ content: Any) -> UISwipeActionsConfiguration? {
        fatalError("Not Implemented")
    }
    
    @available(iOSApplicationExtension 11.0, iOS 11.0, *)
    func trailingSwipeActionsConfigurationInternal(_ content: Any) -> UISwipeActionsConfiguration? {
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
}
