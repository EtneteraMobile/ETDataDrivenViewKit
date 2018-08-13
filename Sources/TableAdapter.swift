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
///
/// - Attention: `TableAdapter` supports only cells (no header/footer).
///               If you want to insert header/footer, it's recommended to use
///               factory, that configures cell as header/footer.
open class TableAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
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

    /// Factories that handles presentation of given content (`data`) into view.
    public var cellFactories: [BaseAbstractFactory] = [] {
        didSet {
            cellFactories.forEach { provider in
                tableView.register(provider.viewClass, forCellReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var headerFactories: [BaseAbstractFactory] = [] {
        didSet {
            headerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var footerFactories: [BaseAbstractFactory] = [] {
        didSet {
            footerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }

    /// Animation configuration for `tableView` updates.
    /// Defaults is `AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)`
    public var animationConfiguration: AnimationConfiguration = AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .bottom)

    // MARK: private

    /// `data` that are delivered to tableView
    private var deliveredData: [TableSection] = []

    /// Managed tableView
    private let tableView: UITableView

    // MARK: - Initialization

    init(tableView: UITableView) {
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
                deliveredData = difference.finalSections
                tableView.performBatchUpdates(difference, animationConfiguration: animationConfiguration)
            }
            deliverHeaderFooterUpdates(oldSections, differences, newSections)
        }
        catch let error {
            #if DEBUG
            print("Unable to deliver data with animation, error: \(error). Starts delivery without animation (reloadData).")
            #endif
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
                    setup(view, with: header, factories: headerFactories)
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
                    setup(view, with: footer, factories: headerFactories)
                    view.layoutSubviews()
                    view.isHidden = false
                } else {
                    view.isHidden = true
                }
            }
        }

        return true
    }

    // MARK: - TableView Delegate & DataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        return deliveredData.count
    }

    // MARK: Header

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return height(for: deliveredData[section].header, factories: headerFactories, width: tableView.frame.width)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerFooterView(for: deliveredData[section].header, factories: headerFactories)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        setup(view, with: deliveredData[section].header, factories: headerFactories)
    }

    // MARK: Rows

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveredData[section].items.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: deliveredData[indexPath.section].items[indexPath.row].value, factories: cellFactories, width: tableView.frame.width)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].value
        for provider in cellFactories {
            if provider.shouldHandleInternal(rowData) {
                let cell = tableView.dequeueReusableCell(withIdentifier: provider.reuseId)!
                let rowData = deliveredData[indexPath.section].items[indexPath.row].value
                setup(cell, with: rowData, factories: cellFactories)
                return cell
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].value
        for provider in cellFactories {
            if provider.shouldHandleInternal(rowData) {
                let cell = tableView.dequeueReusableCell(withIdentifier: provider.reuseId)!
                let rowData = deliveredData[indexPath.section].items[indexPath.row].value
                willDisplay(cell, with: rowData, factories: cellFactories)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].value
        return selectCellProvider(for: rowData).shouldHighlighInternal(rowData)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellProvider(for: rowData).didSelectInternal(rowData)
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].value
        selectCellProvider(for: rowData).accessoryButtonTappedInternal(rowData)
    }

    // MARK: Footer

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return height(for: deliveredData[section].footer, factories: footerFactories, width: tableView.frame.width)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return headerFooterView(for: deliveredData[section].footer, factories: footerFactories)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        setup(view, with: deliveredData[section].footer, factories: footerFactories)
    }

    // MARK: - General

    private func selectCellProvider(for content: Any) -> BaseAbstractFactory {
        for provider in cellFactories {
            if provider.shouldHandleInternal(content) {
                return provider
            }
        }
        fatalError()
    }

    private func height(for content: Any?, factories: [BaseAbstractFactory], width: CGFloat) -> CGFloat {
        if let content = content {
            for provider in factories {
                if provider.shouldHandleInternal(content) {
                    return provider.heightInternal(for: content, width: width)
                }
            }
            fatalError("Missing Factory for content: \(content)")
        }
        return 0.0
    }

    private func setup(_ view: UIView, with content: Any?, factories: [BaseAbstractFactory]) {
        if let content = content {
            for provider in factories {
                if provider.shouldHandleInternal(content) {
                    provider.setupInternal(view, content)
                    return
                }
            }
            fatalError()
        }
    }

    private func willDisplay(_ view: UIView, with content: Any?, factories: [BaseAbstractFactory]) {
        if let content = content {
            for provider in factories {
                if provider.shouldHandleInternal(content) {
                    provider.willDisplayInternal(view, content)
                    return
                }
            }
            fatalError()
        }
    }

    private func headerFooterView(for content: Any?, factories: [BaseAbstractFactory]) -> UIView? {
        if let content = content {
            for provider in factories {
                if provider.shouldHandleInternal(content) {
                    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.reuseId)!
                    return view
                }
            }
            fatalError()
        }
        return nil
    }
}
