//
//  TableView+TableAdapter.swift
//  ETDataDrivenViewKit
//
//  Created by Jan Čislinský on 12. 06. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

private var AssociatedTableAdapter: String = "AssociatedTableAdapter"

public extension UITableView {
    /// `TableAdapter` that delivers data changes into `tableView`.
    public var adapter: TableAdapter {
        get {
            if let adapter = objc_getAssociatedObject(self, &AssociatedTableAdapter) as? TableAdapter {
                return adapter
            } else {
                let adapter = TableAdapter(tableView: self)
                self.adapter = adapter
                return adapter
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedTableAdapter, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
