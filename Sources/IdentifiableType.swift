//
//  IdentifiableType.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 01. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation

public protocol IdentifiableType {
    var identity: Int { get }
}

public typealias AutoIdentifiableType = IdentifiableType & Hashable
public extension IdentifiableType where Self: Hashable {
    var identity: Int {
        return hashValue
    }
}
