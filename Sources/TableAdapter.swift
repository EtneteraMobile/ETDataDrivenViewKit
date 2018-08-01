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
}
