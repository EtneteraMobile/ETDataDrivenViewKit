//
//  CollectionAdapter.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit
import Differentiator

/// `CollectionAdapter` serves as `UICollectionView` **delegate and data source**.
///
/// After `data` assignment adapter call `reloadData` on managed `collectionView`.
///
/// Every **cell is configured by factory** (from `cellFactories`). Factory is
/// used for cell configuration only if **cell's content is same as generic**
/// `AbstractFactory.ContentType`. There can be multiple factories with same
/// ContentType but only the first will be used *everytime*.
open class CollectionAdapter: NSObject {

    /// Result of rows diff.
    ///
    /// - Attention: `import Differentiator`
    public enum DiffResult: CustomStringConvertible {
        case diff([Changeset<CollectionSection>])
        case error(Error)

        public var description: String {
            switch self {
            case .diff(let diff): return "\(diff)"
            case .error(let error): return error.duplicateItemDescription() ?? "\(error)"
            }
        }
    }



    // MARK: - Variables
    // MARK: public

    /// Collection items content that will be delivered into `collectionView`
    /// after assignment.
    public var data: [DiffableType] = [] {
        didSet {
            if Thread.isMainThread {
                deliverData(oldValue, data)
            } else {
                DispatchQueue.main.async {
                    self.deliverData(oldValue, self.data)
                }
            }
        }
    }

    /// `data` that are delivered to collectionView (wrapped in section)
    public var deliveredData: [CollectionSection] = []
    
    /// Factories that handles presentation of given content (`data`) into view.
    public var cellFactories: [_BaseCollectionAbstractFactory] = [] {
        didSet {
            cellFactories.forEach { provider in
                collectionView.register(provider.viewClass, forCellWithReuseIdentifier: provider.reuseId)
            }
        }
    }
    
    /// ScrollView delegate that bridges events to closures
    public let scrollDelegate = ScrollViewDelegate()

    /// Disables delivery animation when collectionView doesn't contain any items
    /// before the update.
    ///
    /// - Attention: Default is `true`
    public var isAnimationDisabledForDeliveryFromEmptyState = true

    /// Triggered after rows diff. This observer is for DEBUG purpose.
    ///
    /// - Attention: `import Differentiator`
    public var rowsDiffResult: ((DiffResult) -> Void)?

    // MARK: private

    /// Managed collectionView
    private weak var collectionView: UICollectionView!
    
    // MARK: - Initializer
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // Loads initial collectionView state
        self.collectionView.reloadData()
    }

    // MARK: - Data Delivery
    // MARK: private

    private func deliverData(_ old: [DiffableType], _ new: [DiffableType]) {
        let oldSection = [CollectionSection(identity: "dataWrapper", rows: old)]
        let newSection = [CollectionSection(identity: "dataWrapper", rows: new)]

        if #available(iOSApplicationExtension 10.0, iOS 10.0, *) {
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        }
        if isAnimationDisabledForDeliveryFromEmptyState && deliveredData.isEmpty {
            // Delivers without animation
            deliveredData = newSection

            collectionView.reloadData()
        } else {
            // Tries to deliver with animation
            do {
                let differences = try Diff.differencesForSectionedView(initialSections: oldSection, finalSections: newSection)
                rowsDiffResult?(.diff(differences))
                for difference in differences {
                    collectionView.performBatchUpdates(difference, deliverData: {
                        deliveredData = difference.finalSections
                    })
                }
            }
            catch let error {
                assertionFailure("Unable to deliver data with animation, error: \(error). Starts delivery without animation (reloadData).")
                rowsDiffResult?(.error(error))
                // Fallback: reloads collection view
                deliveredData = newSection
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: - General
    
    private func selectCellFactory(for indexPath: IndexPath) -> _BaseCollectionAbstractFactory {
        return selectFactory(for: content(at: indexPath), from: cellFactories)
    }
    
    private func selectFactory(for content: Any, from factories: [_BaseCollectionAbstractFactory]) -> _BaseCollectionAbstractFactory {
        // NOTE: Performance optimization with caching [TypeOfContent: Factory]
        for idx in 0..<factories.count {
            let provider = factories[idx]
            if provider.shouldHandleInternal(content) {
                return provider
            }
        }
        fatalError("Factory was not found for content: \(String(reflecting: type(of:content)))")
    }
    
    private func content(at indexPath: IndexPath) -> DiffableType {
        return deliveredData[indexPath.section].rows[indexPath.row]
    }
}

// MARK: - DataSource

extension CollectionAdapter: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return deliveredData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deliveredData[section].rows.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let factory = selectCellFactory(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: factory.reuseId, for: indexPath)
        factory.setupInternal(cell, content(at: indexPath))
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).canMoveInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        selectCellFactory(for: sourceIndexPath).moveInternal(from: sourceIndexPath, to: destinationIndexPath)
    }
}

// MARK: - Delegate

extension CollectionAdapter: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didSelectInternal(content(at: indexPath))
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didDeselectInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldSelectInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldDeselectInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didHighlighInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).didUnhighlighInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldHighlighInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return selectCellFactory(for: indexPath).shouldShowMenuInternal(content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        selectCellFactory(for: indexPath).willDisplayInternal(cell, content(at: indexPath))
    }
    
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        selectCellFactory(for: indexPath).performActionInternal(action: action, for: content(at: indexPath), withSender: sender)
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return selectCellFactory(for: indexPath).canPerformActionInternal(action: action, for: content(at: indexPath), withSender: sender)
    }
}

extension CollectionAdapter: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return selectCellFactory(for: indexPath).sizeForContentInternal(content(at: indexPath))
    }
}
