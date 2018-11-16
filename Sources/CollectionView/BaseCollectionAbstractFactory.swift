//
//  BaseCollectionAbstractFactory.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

open class _BaseCollectionAbstractFactory: _BaseAbstractFactory {
    
    func sizeForContentInternal(_ content: Any) -> CGSize {
        fatalError("Not Implemented")
    }
    
    func shouldSelectInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }
    
    func shouldDeselectInternal(_ content: Any) -> Bool {
        fatalError("Not Implemented")
    }
    
    func didSelectInternal(_ content: Any) {
        fatalError("Not Implemented")
    }
    
    func didDeselectInternal(_ content: Any) {
        fatalError("Not Implemented")
    }
}
