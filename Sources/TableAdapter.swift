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

    /// Factories that handles presentation of given content (`data`) into view.
    public var cellFactories: [_BaseAbstractFactory] = [] {
        didSet {
            cellFactories.forEach { provider in
                tableView.register(provider.viewClass, forCellReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var headerFactories: [_BaseAbstractFactory] = [] {
        didSet {
            headerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var footerFactories: [_BaseAbstractFactory] = [] {
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
        do {
            let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
            for difference in differences {
                tableView.performBatchUpdates(difference, maintainScrollPosition: maintainScrollPosition, animationConfiguration: animationConfiguration, deliverData: {
                    deliveredData = difference.finalSections
                })
            }
            deliverHeaderFooterUpdates(oldSections, differences, newSections)
        }
        catch let error {
            assertionFailure("Unable to deliver data with animation, error: \(error). Starts delivery without animation (reloadData).")
            // Fallback: reloads table view
            deliveredData = newSections
            tableView.reloadData()
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
            let newIdx = newSections.index { newSection in
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
                } else {
                    view.isHidden = true
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
                } else {
                    view.isHidden = true
                }
            }
        }

        return true
    }

    // MARK: - General

    private func selectCellFactory(for indexPath: IndexPath) -> _BaseAbstractFactory {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectFactory(for: content, from: cellFactories)
    }

    private func selectHeaderFactory(for section: Int) -> _BaseAbstractFactory? {
        if let content = deliveredData[section].header {
            return selectFactory(for: content, from: headerFactories)
        }
        return nil
    }

    private func selectFooterFactory(for section: Int) -> _BaseAbstractFactory? {
        if let content = deliveredData[section].footer {
            return selectFactory(for: content, from: footerFactories)
        }
        return nil
    }

    private func selectFactory(for content: Any, from factories: [_BaseAbstractFactory]) -> _BaseAbstractFactory {
        // NOTE: Performance optimization with caching [TypeOfContent: Factory]
        for provider in factories {
            if provider.shouldHandleInternal(content) {
                return provider
            }
        }
        fatalError()
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
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        provider.setupInternal(cell, content)
        return cell
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).canEditInternal(content)
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).canMoveInternal(content)
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        selectCellFactory(for: sourceIndexPath).moveInternal(from: sourceIndexPath, to: destinationIndexPath)
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).commitInternal(editingStyle: editingStyle, for: content)
    }
}

// MARK: Delegate

extension TableAdapter: UITableViewDelegate {
    // Display customization

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).willDisplayInternal(cell, content)
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let content = deliveredData[section].header {
            selectHeaderFactory(for: section)?.willDisplayInternal(view, content)
        }
    }

    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let content = deliveredData[section].footer {
            selectFooterFactory(for: section)?.willDisplayInternal(view, content)
        }
    }

    // Variable height support

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).heightInternal(for: content, width: tableView.frame.width)
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let content = deliveredData[section].header, let factory = selectHeaderFactory(for: section) {
            return factory.heightInternal(for: content, width: tableView.frame.width)
        } else {
            return 0
        }
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let content = deliveredData[section].footer, let factory = selectFooterFactory(for: section) {
            return factory.heightInternal(for: content, width: tableView.frame.width)
        } else {
            return 0
        }
    }

    // Section header & footer information

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let content = deliveredData[section].header, let provider = selectHeaderFactory(for: section) {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.reuseId)!
            view.isHidden = false
            provider.setupInternal(view, content)
            return view
        } else {
            return nil
        }
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let content = deliveredData[section].footer, let provider = selectFooterFactory(for: section) {
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
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).accessoryButtonTappedInternal(content)
    }

    // Selection

    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).shouldHighlighInternal(content)
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).didHighlighInternal(content)
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).didUnhighlighInternal(content)
    }

    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).willSelectInternal(content, indexPath, isEditing: tableView.isEditing)
    }

    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).willDeselectInternal(content, indexPath, isEditing: tableView.isEditing)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).didSelectInternal(content, isEditing: tableView.isEditing)
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).didDeselectInternal(content, isEditing: tableView.isEditing)
    }

    // Editing

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).editingStyleInternal(content)
    }

    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).titleForDeleteConfirmationButtonInternal(content)
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).editActionsInternal(content)
    }

    // Swipe actions

    @available(iOSApplicationExtension 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).leadingSwipeActionsConfigurationInternal(content)
    }

    @available(iOSApplicationExtension 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).trailingSwipeActionsConfigurationInternal(content)
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).shouldIndentWhileEditingInternal(content)
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).willBeginEditingInternal(content)
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            let content = deliveredData[indexPath.section].items[indexPath.row].value
            selectCellFactory(for: indexPath).didEndEditingInternal(content)
        }
    }

    // Moving/reordering

    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return selectCellFactory(for: sourceIndexPath).targetIndexPathForMoveInternal(from: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
    }

    // Indentation

    public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).indentationLevelInternal(content)
    }

    // Copy/Paste

    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).shouldShowMenuInternal(content)
    }

    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellFactory(for: indexPath).canPerformActionInternal(action: action, for: content, withSender: sender)
    }

    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let content = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellFactory(for: indexPath).performActionInternal(action: action, for: content, withSender: sender)
    }
}
