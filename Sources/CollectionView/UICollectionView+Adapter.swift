//
//  UICollectionView+Adapter.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

private var AssociatedCollectionAdapter: String = "AssociatedCollectionAdapter"

public extension UICollectionView {
    /// `CollectionAdapter` that delivers data changes into `collectionView`.
    var adapter: CollectionAdapter {
        get {
            if let adapter = objc_getAssociatedObject(self, &AssociatedCollectionAdapter) as? CollectionAdapter {
                return adapter
            } else {
                let adapter = CollectionAdapter(collectionView: self)
                self.adapter = adapter
                return adapter
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedCollectionAdapter, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
