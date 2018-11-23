//
//  CollectionViewModel.swift
//  ETDataDrivenViewKit-iOS
//
//  Created by Růžička Jakub on 16/11/2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import ETDataDrivenViewKit

protocol CollectionViewModelType {
    typealias Model = [DiffableType]
    
    var model: Model { get }
    var didUpdateModel: ((Model) -> Void)? { get set }
    func loadData()
}

class CollectionViewModel: CollectionViewModelType  {
    private(set) var model: [DiffableType] = [] {
        didSet {
            didUpdateModel?(model)
        }
    }
    
    var didUpdateModel: ((Model) -> Void)?
    
    func loadData() {
        var data: [DiffableType] = []
        
        for i in 0..<99 {
            if i % 2 == 0 {
                data.append(GreenCell())
            } else {
                data.append(RedCell())
            }
        }
        
        model = data
    }
}

struct GreenCell: DiffableHashableType {
    var identity: Int {
        return hashValue
    }
}

struct RedCell: DiffableHashableType {
    var identity: Int {
        return hashValue
    }
}
