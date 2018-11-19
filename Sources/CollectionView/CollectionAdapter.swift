//
//  CollectionAdapter.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit

open class CollectionAdapter: NSObject {
    
    // MARK: - Variables
    // MARK: public
    
    public var data: [DiffableType] = [] {
        didSet {
            //TODO: deliver only diff. It is OK like this for now.
            collectionView.reloadData()
        }
    }
    
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
    
    // MARK: private
    
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
    
    // MARK: - General
    
    private func selectCellFactory(for indexPath: IndexPath) -> _BaseCollectionAbstractFactory {
        let content = data[indexPath.row]
        return selectFactory(for: content, from: cellFactories)
    }
    
    private func selectFactory(for content: Any, from factories: [_BaseCollectionAbstractFactory]) -> _BaseCollectionAbstractFactory {
        // NOTE: Performance optimization with caching [TypeOfContent: Factory]
        for provider in factories {
            if provider.shouldHandleInternal(content) {
                return provider
            }
        }
        fatalError()
    }
    
    private func content(at indexPath: IndexPath) -> DiffableType {
        return data[indexPath.row]
    }
}

// MARK: - DataSource

extension CollectionAdapter: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
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
