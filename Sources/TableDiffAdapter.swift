//
//  TableDiffAdapter.swift
//  Etnetera a. s.
//
//  Created by Jan Cislinsky on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s.. All rights reserved.
//

import Foundation
import UIKit

public class TableDiffAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
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

    public var cellFactories: [CellFactoryType] = [] {
        didSet {
            cellFactories.forEach { provider in
                tableView.register(provider.viewClass, forCellReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var headerFactories: [HeaderFooterFactoryType] = [] {
        didSet {
            headerFactories.forEach { provider in
                tableView.register(provider.viewClass, forHeaderFooterViewReuseIdentifier: provider.reuseId)
            }
        }
    }
    public var footerFactories: [HeaderFooterFactoryType] = [] {
        didSet {
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

    public init(tableView: UITableView) {
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
        if let headerData = deliveredData[section].header {
            for provider in headerFactories {
                if provider.shouldHandle(headerData) {
                    switch provider.heightDimension {
                    case .automatic:
                        return UITableViewAutomaticDimension
                    case let .calculate(calc):
                        return calc(headerData)
                    }
                }
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerData = deliveredData[section].header {
            for provider in headerFactories {
                if provider.shouldHandle(headerData) {
                    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.reuseId)!
                    provider.setup(view, with: headerData)
                    return view
                }
            }
            fatalError()
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerData = deliveredData[section].header {
            for provider in headerFactories {
                if provider.shouldHandle(headerData) {
                    provider.setup(view, with: headerData)
                    return
                }
            }
            fatalError()
        }
    }

    // MARK: Rows

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowdata = deliveredData[indexPath.section].rows[indexPath.row]
        for provider in cellFactories {
            if provider.shouldHandle(rowdata) {
                switch provider.heightDimension {
                case .automatic:
                    return UITableViewAutomaticDimension
                case let .calculate(calc):
                    return calc(rowdata)
                }
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveredData[section].rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowdata = deliveredData[indexPath.section].rows[indexPath.row]
        for provider in cellFactories {
            if provider.shouldHandle(rowdata) {
                return tableView.dequeueReusableCell(withIdentifier: provider.reuseId)!
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowdata = deliveredData[indexPath.section].rows[indexPath.row]
        for provider in cellFactories {
            if provider.shouldHandle(rowdata) {
                provider.setup(cell, with: rowdata)
                return
            }
        }
        fatalError()
    }

    // MARK: Footer

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let footerData = deliveredData[section].footer {
            for provider in footerFactories {
                if provider.shouldHandle(footerData) {
                    switch provider.heightDimension {
                    case .automatic:
                        return UITableViewAutomaticDimension
                    case let .calculate(calc):
                        return calc(footerData)
                    }
                }
            }
        }
        fatalError()
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footerData = deliveredData[section].footer {
            for provider in footerFactories {
                if provider.shouldHandle(footerData) {
                    let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.reuseId)!
                    provider.setup(view, with: footerData)
                    return view
                }
            }
            fatalError()
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerData = deliveredData[section].footer {
            for provider in footerFactories {
                if provider.shouldHandle(footerData) {
                    provider.setup(view, with: footerData)
                    return
                }
            }
            fatalError()
        }
    }
}
