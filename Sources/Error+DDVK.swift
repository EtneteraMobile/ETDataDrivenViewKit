//
//  Error+DDVK.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 26. 03. 2019.
//  Copyright © 2019 Etnetera a. s. All rights reserved.
//

import Foundation
import Differentiator

extension Error {
    func duplicateItemDescription() -> String? {
        if let error = self as? Differentiator.Diff.Error, case .duplicateItem(let item) = error, let diffRef = item as? DiffableRef {
            return "[Diff failed] Duplicate item \(String(reflecting: type(of: diffRef.value))): \(diffRef.value)"
        }
        return nil
    }
}
