//
//  UI+SectionedViewType.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Jan Čislinský on 17. 08. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit
import Differentiator

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension UITableView {

    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteRows(at: paths, with: animationStyle)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadRows(at: paths, with: animationStyle)
    }

    public func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections), with: animationStyle)
    }

    public func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections), with: animationStyle)
    }

    public func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections), with: animationStyle)
    }

    public func performBatchUpdates<S>(_ changes: Changeset<S>, maintainScrollPosition: Bool, animationConfiguration: AnimationConfiguration, deliverData: () -> Void) {
        var newContentOffset: CGPoint?
        if let firstVisibleIndexPath = indexPathsForVisibleRows?.first, maintainScrollPosition {
            var heightDeltaAboveVisibleRows: CGFloat = 0
            heightDeltaAboveVisibleRows -= changes.deletedSections
                .filter { $0 < firstVisibleIndexPath.section }
                .map { sectionHeight($0) }
                .reduce(CGFloat(0.0)) { $0 + $1 }
            heightDeltaAboveVisibleRows -= changes.deletedItems
                .filter { $0.sectionIndex <= firstVisibleIndexPath.section && $0.itemIndex < firstVisibleIndexPath.row }
                .map { rowHeight(IndexPath(row: $0.itemIndex, section: $0.sectionIndex)) }
                .reduce(CGFloat(0.0)) { $0 + $1 }

            deliverData()

            heightDeltaAboveVisibleRows += changes.insertedSections
                .filter { $0 <= firstVisibleIndexPath.section }
                .map { sectionHeight($0) }
                .reduce(CGFloat(0.0)) { $0 + $1 }
            heightDeltaAboveVisibleRows += changes.insertedItems
                .filter { $0.sectionIndex < firstVisibleIndexPath.section || $0.sectionIndex == firstVisibleIndexPath.section && $0.itemIndex < firstVisibleIndexPath.row }
                .map { rowHeight(IndexPath(row: $0.itemIndex, section: $0.sectionIndex)) }
                .reduce(CGFloat(0.0)) { $0 + $1 }

            if heightDeltaAboveVisibleRows != 0 {
                newContentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + heightDeltaAboveVisibleRows)
            }
        } else {
            deliverData()
        }

        if newContentOffset != nil {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        
        beginUpdates()
        deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
        // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
        // otherwise all cells will be reloaded for nothing.
        //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
        insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
        for (from, to) in changes.movedSections {
            moveSection(from, to: to)
        }

        deleteItemsAtIndexPaths(
            changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.deleteAnimation
        )

        insertItemsAtIndexPaths(
            changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.insertAnimation
        )

        reloadItemsAtIndexPaths(
            changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.reloadAnimation
        )

        for (from, to) in changes.movedItems {
            moveItemAtIndexPath(
                IndexPath(item: from.itemIndex, section: from.sectionIndex),
                to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
            )
        }
        endUpdates()

        if let newContentOffset = newContentOffset {
            setContentOffset(newContentOffset, animated: false)
            CATransaction.commit()
        }
    }

    private func rowHeight(_ indexPath: IndexPath) -> CGFloat {
        if let rVal = delegate?.tableView?(self, heightForRowAt: indexPath) {
            precondition(rVal != UITableViewAutomaticDimension, "TableAdapter has set maintainScrollPosition = true but it doesn't support UITableViewAutomaticDimension that is used somewhere.")
            return rVal
        }
        return 0.0
    }

    private func sectionHeight(_ idx: Int) -> CGFloat {
        guard let delegate = delegate, let dataSource = dataSource else {
            return 0.0
        }

        let headerHeight = delegate.tableView?(self, heightForHeaderInSection: idx) ?? 0
        let rowsHeight = stride(from: 0, to: dataSource.tableView(self, numberOfRowsInSection: idx), by: 1).reduce(CGFloat(0.0)) {
            $0 + rowHeight(IndexPath(row: $1, section: idx))
        }
        let footerHeight = delegate.tableView?(self, heightForFooterInSection: idx) ?? 0

        return headerHeight + footerHeight + rowsHeight
    }
}
