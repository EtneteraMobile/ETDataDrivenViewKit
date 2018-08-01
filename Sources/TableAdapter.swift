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

public class TableAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    public typealias Data = [TableSection]

    // MARK: - Variables
    // MARK: public

    public var data: Data = [] {
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

    public var animationConfiguration: AnimationConfiguration

    // MARK: private

    /// `data` that are delivered to tableView
    private var deliveredData: Data = []

    /// Managed tableView
    private let tableView: UITableView

    // MARK: - Initialization

    init(tableView: UITableView, animationConfiguration: AnimationConfiguration = AnimationConfiguration(insertAnimation: .left, reloadAnimation: .middle, deleteAnimation: .right)) {
        self.tableView = tableView
        self.animationConfiguration = animationConfiguration
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Loads initial tableView state
        tableView.reloadData()
    }

    // MARK: - Data Delivery
    // MARK: private

    private func deliverData(_ oldSections: TableAdapter.Data, _ newSections: TableAdapter.Data) {
        if #available(iOSApplicationExtension 10.0, *) {
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        }
        do {
            let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
            for difference in differences {
                deliveredData = difference.finalSections
                tableView.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
            }
        }
        catch let error {
            #if DEBUG
            print("Unable to deliver data with animation, error: \(error). Starts delivery without animation (`reloadData`)")
            #endif
            // Fallback: reloads table view
            deliveredData = newSections
            tableView.reloadData()
        }
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
        return height(for: deliveredData[indexPath.section].items[indexPath.row].content, factories: cellFactories, width: tableView.frame.width)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].content
        for provider in cellFactories {
            if provider.shouldHandleInternal(rowData) {
                let cell = tableView.dequeueReusableCell(withIdentifier: provider.reuseId)!
                let rowData = deliveredData[indexPath.section].items[indexPath.row].content
                setup(cell, with: rowData, factories: cellFactories)
                return cell
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].content
        for provider in cellFactories {
            if provider.shouldHandleInternal(rowData) {
                let cell = tableView.dequeueReusableCell(withIdentifier: provider.reuseId)!
                let rowData = deliveredData[indexPath.section].items[indexPath.row].content
                willDisplay(cell, with: rowData, factories: cellFactories)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].content
        return selectCellProvider(for: rowData).shouldHighlighInternal(rowData)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].content
        selectCellProvider(for: rowData).didSelectInternal(rowData)
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].items[indexPath.row].content
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
