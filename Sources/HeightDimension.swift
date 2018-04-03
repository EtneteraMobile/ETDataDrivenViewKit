//
//  HeightDimension.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import UIKit

public enum HeightDimension {
    /// Using autolayout (UITableViewAutomaticDimension)
    case automatic
    /// Using value returned from associated calculation closure
    case calculate((Any) -> CGFloat)
}
