//
//  CollectionViewController.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import UIKit
import ETDataDrivenViewKit

class CollectionViewController: UICollectionViewController {
    
    @IBOutlet var reloadBarButton: UIBarButtonItem?
    
    lazy var viewModel: CollectionViewModelType = CollectionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.adapter.cellFactories = [GreenCellFactory(), RedCellFactory()]
        collectionView.adapter.rowsDiffResult = { diff in
            print(diff)
        }
        viewModel.didUpdateModel = { [weak collectionView] model in
            collectionView?.adapter.data = model
        }
        viewModel.loadData()
    }
    
    @IBAction func reloadBarButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.loadData()
    }

    class GreenCellFactory: AbstractCollectionCellFactory<GreenCell, UICollectionViewCell> {
        
        override func setup(_ view: UICollectionViewCell, _ content: GreenCell) {
            view.backgroundColor = .green
        }
        
        override func sizeForContent(_ content: GreenCell) -> CGSize {
            return CGSize(width: 100, height: 100)
        }
    }
    
    class RedCellFactory: AbstractCollectionCellFactory<RedCell, UICollectionViewCell> {
        
        override func setup(_ view: UICollectionViewCell, _ content: RedCell) {
            view.backgroundColor = .red
        }
        
        override func sizeForContent(_ content: RedCell) -> CGSize {
            return CGSize(width: 100, height: 100)
        }
    }
}
