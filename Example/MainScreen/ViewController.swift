//
//  ViewController.swift
//  example
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import UIKit
import ETDataDrivenViewKit

class ViewController: UITableViewController {

    let viewModel: ViewModelType = ViewModel()
    private lazy var tableAdapter: TableDiffAdapter = TableDiffAdapter(tableView: tableView)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        tableAdapter.headerFactories = [HeaderProvider()]
        tableAdapter.cellFactories = [GreenCellFactory(), YellowCellFactory()]
        tableAdapter.footerFactories = [FooterProvider()]

        viewModel.didUpdateModel = { model in
            self.tableAdapter.data = model
        }
        viewModel.loadData()
    }

    // MARK: - Cell factories

    class GreenCellFactory: AbstractCellFactory<GreenRow, UITableViewCell> {
        override var heightDimension: HeightDimension {
            return .calculate({ [unowned self] content in
                if let content = self.toTypedContent(content) {
                    let height = NSAttributedString(string: content.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
                    return CGFloat(ceilf(Float(height))) + 20 // padding
                }
                fatalError("Unsupported content")
            })
        }
        override func setup(_ cell: UITableViewCell, with content: Any) {
            guard let cell = toTypedView(cell), let content = toTypedContent(content) else {
                return
            }
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = content.text
            cell.backgroundColor = .green
        }
    }

    class YellowCellFactory: AbstractCellFactory<YellowRow, UITableViewCell> {
        override func setup(_ cell: UITableViewCell, with content: Any) {
            guard let cell = toTypedView(cell), let content = toTypedContent(content) else {
                return
            }
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = content.text
            cell.backgroundColor = .yellow
        }
    }

    // MARK: - Header/Footer factories

    class HeaderProvider: AbstractHeaderFooterFactory<Header, UITableViewHeaderFooterView> {
        override var heightDimension: HeightDimension {
            return .calculate({ _ in 32.0 })
        }
        override func setup(_ view: UIView, with content: Any) {
            guard let view = toTypedView(view), let content = toTypedContent(content) else {
                fatalError()
            }
            view.textLabel?.text = content.text
        }
    }

    class FooterProvider: AbstractHeaderFooterFactory<Footer, UITableViewHeaderFooterView> {
        override var heightDimension: HeightDimension {
            return .calculate({ _ in 32.0 })
        }
        override func setup(_ view: UIView, with content: Any) {
            guard let view = toTypedView(view), let content = toTypedContent(content) else {
                fatalError()
            }
            view.textLabel?.text = content.text
        }
    }
}

