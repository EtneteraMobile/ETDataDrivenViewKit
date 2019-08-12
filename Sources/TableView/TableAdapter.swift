//
//  TableAdapter.swift
//  Etnetera a. s.
//
//  Created by Jan Cislinsky on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s.. All rights reserved.
//

import Foundation
import UIKit
import Differentiator

/// `TableAdapter` serves as `UITableView` **delegate and data source**.
///
/// After `data` assignment **advanced diffing algorithm** recognizes content
/// changes and trigger `tableView` update.
///
/// **Changes** in tableView are **presented with animation** defined by
/// `animationConfiguration`.
///
/// Every **cell is configured by factory** (from `cellFactories`). Factory is
/// used for cell configuration only if **cell's content is same as generic**
/// `AbstractFactory.ContentType`. There can be multiple factories with same
/// ContentType but only the first will be used *everytime*.
open class TableAdapter: NSObject  {
    /// Result of rows diff.
    ///
    /// - Attention: `import Differentiator`
    public enum DiffResult: CustomStringConvertible {
        case diff([Changeset<TableSection>])
        case error(Error)

        public var description: String {
            switch self {
            case .diff(let diff): return "\(diff)"
            case .error(let error): return error.duplicateItemDescription() ?? "\(error)"
            }
        }
    }

    // MARK: - Variables
    // MARK: public

    /// Table sections content that will be delivered into `tableView` after assignment.
    public var data: [TableSection] = [] {
        didSet {
            if Thread.isMainThread {
                deliverData(oldValue, data)
            } else {
                DispatchQueue.main.async {
                    self.deliverData(oldValue, self.data)
                }
            }
        }
    }

    /// `data` that are delivered to tableView
    public var deliveredData: [TableSection] = []

    /// Factories that handles presentation of given **cell** content (`data`) into view.
    public var cellFactories: [_BaseTableAbstractFactory] = [] {
        didSet {
            cellFactories.forEach { provider in
                tableView.register(provider.viewClass, forCellReuseIdentifier: provider.reuseId)
            }
        }
    }
    /// Factories that handles presentation of given **header** content (`data`) into view.
    public var headerFactories: [_BaseTableAbstractFactory] = [] {
        didSet {
            headerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }
    /// Factories that handles presentation of given **footer** content (`data`) into view.
    public var footerFactories: [_BaseTableAbstractFactory] = [] {
        didSet {
            footerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }

    /// Animation configuration for `tableView` updates.
    /// Defaults is `AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)`
    public var animationConfiguration: AnimationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)

    /// ScrollView delegate that bridges events to closures
    public let scrollDelegate = ScrollViewDelegate()

    /// If is enabled it adjusts `tableView.contentOffset` to maintain scroll
    /// position between updates.
    ///
    /// - Precondition: UITableViewAutomaticDimension isn't supported.
    ///
    /// - Warning: This feature is experimental. **Supports only insertation and
    /// deletion of rows and sections.**
    ///
    /// By default `tableView` changes `contentOffset` if row is
    /// inserted/removed above visible rows. Visible rows moves down/up and new
    /// rows appears on top.
    ///
    /// Defaults is `false`.
    ///
    /// Related in different library. [IGListKit: Add option to maintain scroll position when performing updates](https://github.com/Instagram/IGListKit/issues/242)
    public var maintainScrollPosition = false

    /// Triggered after rows diff. This observer is for DEBUG purpose.
    ///
    /// - Attention: `import Differentiator`
    public var rowsDiffResult: ((DiffResult) -> Void)?

    /// Disables delivery animation when tableView doesn't contain any rows
    /// before the update.
    ///
    /// - Attention: Default is `true`
    public var isAnimationDisabledForDeliveryFromEmptyState = true

    // MARK: private

    /// Managed tableView
    private weak var tableView: UITableView!

    // MARK: - Initialization

    public init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Loads initial tableView state
        self.tableView.reloadData()
    }

    // MARK: - Data Delivery
    // MARK: private

    private func deliverData(_ oldSections: [TableSection], _ newSections: [TableSection]) {
        if #available(iOSApplicationExtension 10.0, *) {
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        }
        if isAnimationDisabledForDeliveryFromEmptyState && deliveredData.isEmpty {
            // Delivers without animation
            deliveredData = newSections
            tableView.reloadData()
        } else {
            // Tries to deliver with animation
            do {
                let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                rowsDiffResult?(.diff(differences))
                for difference in differences {
                    tableView.performBatchUpdates(difference, maintainScrollPosition: maintainScrollPosition, animationConfiguration: animationConfiguration, deliverData: {
                        deliveredData = difference.finalSections
                    })
                }
                deliverHeaderFooterUpdates(oldSections, differences, newSections)
                logChanges(differences)
            }
            catch let error {
                assertionFailure("Unable to deliver data with animation, error: \(error). Starts delivery without animation (reloadData).")
                rowsDiffResult?(.error(error))
                // Fallback: reloads table view
                deliveredData = newSections
                tableView.reloadData()
                if let errorDescription = error.duplicateItemDescription() {
                    Logger.error(errorDescription)
                } else {
                    Logger.error("[Diff failed] Error: \(error)")
                }
            }
        }
    }

    /// Updates headers/footers in tableView. `Diff` from `Differentiator`
    /// delivers only insert/remove section and insert/reload/remove rows.
    private func deliverHeaderFooterUpdates(_ oldSections: [TableSection], _ differences: [Changeset<TableSection>], _ newSections: [TableSection]) {
        var old = oldSections

        // Removes deleted sections
        let allDeletedSections = differences.flatMap { $0.deletedSections }
        allDeletedSections.sorted(by: >).forEach { deleteIdx in
            old.remove(at: deleteIdx)
        }

        // Finds pairs (old, new) according section identity
        let equalIdentityPairs: [(old: TableSection, new: TableSection, finalIdx: Int)] = old.compactMap { oldSection in
            let newIdx = newSections.firstIndex { newSection in
                return newSection.identity == oldSection.identity
            }
            if let newIdx = newIdx {
                return (oldSection, newSections[newIdx], newIdx)
            }
            return nil
        }

        // Delivers update
        var needUpdate = false
        equalIdentityPairs.forEach { pair in
            needUpdate = deliverHeaderFooterUpdate(pair)
        }

        // Animates the change in the row heights without reloading the cell
        if needUpdate {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    private func deliverHeaderFooterUpdate(_ pair: (old: TableSection, new: TableSection, finalIdx: Int)) -> Bool {
        let headerIdentAndValueEqual = pair.old.header === pair.new.header && pair.old.header == pair.new.header
        let footerIdentAndValueEqual = pair.old.footer === pair.new.footer && pair.old.footer == pair.new.footer

        if headerIdentAndValueEqual && footerIdentAndValueEqual {
            return false
        }

        // Saves new header & footer
        let orig = deliveredData[pair.finalIdx]
        deliveredData[pair.finalIdx] = TableSection(identity: orig.identity, header: pair.new.header, rows: orig.rows, footer: pair.new.footer)

        // Updates header
        if headerIdentAndValueEqual == false {
            if let view = self.tableView.headerView(forSection: pair.finalIdx) {
                if let header = pair.new.header {
                    selectHeaderFactory(for: pair.finalIdx)?.setupInternal(view, header)
                    view.layoutSubviews()
                    view.isHidden = false
                    Logger.log("Inserted/updated section header at index \(pair.finalIdx)")
                } else {
                    view.isHidden = true
                    Logger.log("Deleted section header at index \(pair.finalIdx)")
                }
            }
        }

        // Updates footer
        if footerIdentAndValueEqual == false {
            if let view = self.tableView.footerView(forSection: pair.finalIdx) {
                if let footer = pair.new.footer {
                    selectFooterFactory(for: pair.finalIdx)?.setupInternal(view, footer)
                    view.layoutSubviews()
                    view.isHidden = false
                    Logger.log("Inserted/updated section footer at index \(pair.finalIdx)")
                } else {
                    view.isHidden = true
                    Logger.log("Deleted section footer at index \(pair.finalIdx)")
                }
            }
        }

        return true
    }
    
    private func logChanges(_ differences: [Changeset<TableSection>]) {
        for difference in differences {
            if difference.insertedSections.count > 0 {
                Logger.log("Inserted \(difference.insertedSections.count) sections at \(difference.insertedSections)")
            } else if difference.deletedSections.count > 0 {
                Logger.log("Deleted \(difference.deletedSections.count) sections at \(difference.deletedSections)")
            } else if difference.movedSections.count > 0 {
                Logger.log("Moved \(difference.movedSections.count) sections \(difference.movedSections)")
            } else if difference.updatedSections.count > 0 {
                Logger.log("Updated \(difference.updatedSections.count) sections at \(difference.updatedSections)")
            } else if difference.insertedItems.count > 0 {
                Logger.log("Inserted \(difference.insertedItems.count) items at \(difference.insertedItems)")
            } else if difference.deletedItems.count > 0 {
                Logger.log("Deleted \(difference.deletedItems.count) items at \(difference.deletedItems)")
            } else if difference.movedItems.count > 0 {
                Logger.log("Moved \(difference.movedItems.count) items \(difference.movedItems)")
            } else if difference.updatedItems.count > 0{
                Logger.log("Updated \(difference.updatedItems.count) items at \(difference.updatedItems)")
            }
        }
    }

    // MARK: - General

    private func selectCellFactory(for indexPath: IndexPath) -> _BaseTableAbstractFactory {
        return selectFactory(for: content(at: indexPath), from: cellFactories)
    }

    private func selectHeaderFactory(for section: Int) -> _BaseTableAbstractFactory? {
        if let content = headerContent(at: section) {
            return selectFactory(for: content, from: headerFactories)
        }
        return nil
    }

    private func selectFooterFactory(for section: Int) -> _BaseTableAbstractFactory? {
        if let content = footerContent(at: section) {
            return selectFactory(for: content, from: footerFactories)
        }
        return nil
    }

    private func selectFactory(for content: Any, from factories: [_BaseTableAbstractFactory]) -> _BaseTableAbstractFactory {
        // NOTE: Performance optimization with caching [TypeOfContent: Factory]
        for idx in 0..<factories.count {
            let provider = factories[idx]
            if provider.shouldHandleInternal(content) {
                return provider
            }
        }
        fatalError("Factory was not found for content: \(String(reflecting: type(of:content)))")
    }

    private func content(at indexPath: IndexPath) -> DiffableType {
        return deliveredData[indexPath.section].items[indexPath.row].value
    }

    private func headerContent(at index: Int) -> DiffableType? {
        return deliveredData[index].header
    }

    private func footerContent(at index: Int) -> DiffableType? {
        return deliveredData[index].footer
    }
}

// MARK: - TableView
// MARK: DataSource

extension TableAdapter: UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return deliveredData.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveredData[section].items.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let provider = selectCellFactory(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: provider.reuseId, for: indexPath)
        provider.setupInternal(cell, content(at: indexPath))
        return cell
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).canEditInternal(content(at: indexPath))
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).canMoveInternal(content(at: indexPath))
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        selectCellFactory(for: sourceIndexPath).moveInternal(from: sourceIndexPath, to: destinationIndexPath)
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        return selectCellFactory(for: indexPath).commitInternal(editingStyle: editingStyle, for: content(at: indexPath))
    }
}

// MARK: Delegate

extension TableAdapter: UITableViewDelegate {
    // Display customization

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).willDisplayInternal(cell, content(at: indexPath))
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let content = headerContent(at: section) {
            selectHeaderFactory(for: section)?.willDisplayInternal(view, content)
        }
    }

    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let content = footerContent(at: section) {
            selectFooterFactory(for: section)?.willDisplayInternal(view, content)
        }
    }

    // Variable height support

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectCellFactory(for: indexPath).heightInternal(for: content(at: indexPath), width: tableView.frame.width)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let content = headerContent(at: section), let factory = selectHeaderFactory(for: section) {
            return factory.heightInternal(for: content, width: tableView.frame.width)
        } else {
            return 0
        }
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let content = footerContent(at: section), let factory = selectFooterFactory(for: section) {
            return factory.heightInternal(for: content, width: tableView.frame.width)
        } else {
            return 0
        }
    }

    // Section header & footer information

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let content = headerContent(at: section), let provider = selectHeaderFactory(for: section) {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.reuseId)!
            view.isHidden = false
            provider.setupInternal(view, content)
            return view
        } else {
            return nil
        }
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let content = footerContent(at: section), let provider = selectFooterFactory(for: section) {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.reuseId)!
            view.isHidden = false
            provider.setupInternal(view, content)
            return view
        } else {
            return nil
        }
    }

    // Accessories (disclosures).

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectCellFactory(for: indexPath).accessoryButtonTappedInternal(content(at: indexPath))
    }

    // Selection

    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldHighlighInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didHighlighInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didUnhighlighInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return selectCellFactory(for: indexPath).willSelectInternal(content(at: indexPath), indexPath, isEditing: tableView.isEditing)
    }

    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return selectCellFactory(for: indexPath).willDeselectInternal(content(at: indexPath), indexPath, isEditing: tableView.isEditing)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didSelectInternal(content(at: indexPath), isEditing: tableView.isEditing)
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didDeselectInternal(content(at: indexPath), isEditing: tableView.isEditing)
    }

    // Editing

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return selectCellFactory(for: indexPath).editingStyleInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return selectCellFactory(for: indexPath).titleForDeleteConfirmationButtonInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return selectCellFactory(for: indexPath).editActionsInternal(content(at: indexPath))
    }

    // Swipe actions

    @available(iOSApplicationExtension 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return selectCellFactory(for: indexPath).leadingSwipeActionsConfigurationInternal(content(at: indexPath))
    }

    @available(iOSApplicationExtension 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return selectCellFactory(for: indexPath).trailingSwipeActionsConfigurationInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldIndentWhileEditingInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).willBeginEditingInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            selectCellFactory(for: indexPath).didEndEditingInternal(content(at: indexPath))
        }
    }

    // Moving/reordering

    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return selectCellFactory(for: sourceIndexPath).targetIndexPathForMoveInternal(from: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
    }

    // Indentation

    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return selectCellFactory(for: indexPath).indentationLevelInternal(content(at: indexPath))
    }

    // Copy/Paste

    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldShowMenuInternal(content(at: indexPath))
    }

    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return selectCellFactory(for: indexPath).canPerformActionInternal(action: action, for: content(at: indexPath), withSender: sender)
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        selectCellFactory(for: indexPath).performActionInternal(action: action, for: content(at: indexPath), withSender: sender)
    }
}
