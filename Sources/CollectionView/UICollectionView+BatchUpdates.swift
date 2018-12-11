//
//  UICollectionView+BatchUpdates.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 07/12/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit
import Differentiator

extension UICollectionView {

    public func performBatchUpdates<S>(_ changes: Changeset<S>, deliverData: () -> Void) {
        deliverData()

        performBatchUpdates({
            deleteSections(IndexSet(changes.deletedSections))
            // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
            // otherwise all cells will be reloaded for nothing.
            //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
            insertSections(IndexSet(changes.insertedSections))
            for (from, to) in changes.movedSections {
                moveSection(from, toSection: to)
            }

            deleteItems(at: changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) })

            insertItems(at: changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) })

            reloadItems(at: changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) })

            for (from, to) in changes.movedItems {
                moveItem(at: IndexPath(item: from.itemIndex, section: from.sectionIndex), to: IndexPath(item: to.itemIndex, section: to.sectionIndex))
            }
        },completion: nil)
    }
}
