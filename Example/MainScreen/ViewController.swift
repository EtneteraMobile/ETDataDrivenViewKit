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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none

        tableView.adapter.headerFactories = [HeaderFooterFactory()]
        tableView.adapter.cellFactories = [GreenCellFactory(), YellowCellFactory()]
        tableView.adapter.footerFactories = [HeaderFooterFactory()]

        viewModel.didUpdateModel = { model in
            self.tableView.adapter.data = model
        }
        viewModel.loadData()
    }

    // MARK: - Cell factories

    class GreenCellFactory: AbstractCellFactory<GreenCellFactory.Content, UITableViewCell> {
        override func height(for content: Content, width: CGFloat) -> CGFloat {
            let height = NSAttributedString(string: content.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
            return CGFloat(ceilf(Float(height))) + 20 // padding
        }
        override func setup(_ view: UITableViewCell, _ content: Content) {
            view.textLabel?.numberOfLines = 0
            view.textLabel?.text = content.text
            view.backgroundColor = .green
            view.accessoryType = .detailButton
        }
        override func shouldHighligh(_ content: Content) -> Bool {
            return true
        }
        override func didSelect(_ content: Content) {
            print("didSelect")
        }
        override func accessoryButtonTapped(_ content: Content) {
            print("accessoryButtonTapped")
        }

        struct Content {
            let text: String
        }
    }

    class YellowCellFactory: AbstractCellFactory<YellowCellFactory.Content, UITableViewCell> {

        init() {
            super.init(registration: .customDequeue({ (tableView) -> AnyObject in
                return UITableViewCell()
            }))
        }

        override func setup(_ view: UITableViewCell, _ content: Content) {
            view.textLabel?.numberOfLines = 0
            view.textLabel?.text = content.text
            view.backgroundColor = .yellow
        }

        struct Content {
            let text: String
        }
    }

    // MARK: - Header/Footer factories

    class HeaderFooterFactory: AbstractFactory<HeaderFooter, UITableViewHeaderFooterView> {
        override func height(for content: HeaderFooter, width: CGFloat) -> CGFloat {
            return 32.0
        }
        override func setup(_ view: UITableViewHeaderFooterView, _ content: HeaderFooter) {
            view.textLabel?.text = content.text
        }
    }
}

