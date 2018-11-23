//
//  AbstractTableHeaderFooterFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 22. 11. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

/// Abstract factory for Table header or footer view
open class AbstractTableHeaderFooterFactory<ContentType, View: UITableViewHeaderFooterView>: BaseTableAbstractFactory<ContentType, View> {}
