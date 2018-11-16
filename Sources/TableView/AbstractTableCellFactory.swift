//
//  AbstractCellFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Abstract factory for cell
open class AbstractTableCellFactory<ContentType, View: UITableViewCell>: BaseTableAbstractFactory<ContentType, View> {
    
}

/// Abstract factory for cell
open class AbstractTableHeaderFooterFactory<ContentType, View: UITableViewHeaderFooterView>: BaseTableAbstractFactory<ContentType, View> {
    
}
