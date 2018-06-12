//
//  TableAdapter.swift
//  Etnetera a. s.
//
//  Created by Jan Cislinsky on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s.. All rights reserved.
//

import Foundation
import UIKit

public class TableAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    public typealias Data = [TableSection]

    // MARK: - Variables
    // MARK: public

    public var data: Data = [] {
        didSet {
            // TODO: Diff
            deliveredData = data
            tableView.reloadData()
        }
    }

    public var cellFactories: [BaseAbstractFactory] = [] {
        didSet {
            cellFactories.checkValidity()
            cellFactories.forEach { provider in
                tableView.register(provider.viewClass, forCellReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var headerFactories: [BaseAbstractFactory] = [] {
        didSet {
            cellFactories.checkValidity()
            headerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var footerFactories: [BaseAbstractFactory] = [] {
        didSet {
            cellFactories.checkValidity()
            footerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }

    // MARK: private

    /// `data` that are delivered to tableView
    private var deliveredData: Data = []

    /// Managed tableView
    private let tableView: UITableView

    // MARK: - Initialization

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Loads initial tableView state
        tableView.reloadData()
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
        return deliveredData[section].rows.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height(for: deliveredData[indexPath.section].rows[indexPath.row], factories: cellFactories, width: tableView.frame.width)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = deliveredData[indexPath.section].rows[indexPath.row]
        for provider in cellFactories {
            if provider.shouldHandleInternal(rowData) {
                return tableView.dequeueReusableCell(withIdentifier: provider.reuseId)!
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].rows[indexPath.row]
        setup(cell, with: rowData, factories: cellFactories)
    }

    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let rowData = deliveredData[indexPath.section].rows[indexPath.row]
        return selectCellProvider(for: rowData).shouldHighlighInternal(rowData)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].rows[indexPath.row]
        selectCellProvider(for: rowData).didSelectInternal(rowData)
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let rowData = deliveredData[indexPath.section].rows[indexPath.row]
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
        }
        fatalError()
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

extension Collection where Element: BaseAbstractFactory {
    func checkValidity() {
        precondition(Set(map { "\(type(of: $0))" }).count == count, "Multiple factories of same type isn't supported.")
        precondition(Set(map { "\($0.contentClass.self)" }).count == count, "Same ContentType for multiple factories isn't supported.")
    }
}
