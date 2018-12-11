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

    private var counter = 0
    
    func loadData() {
        var data: [DiffableType] = []

        if counter % 2 == 0 {
            data = [
                RedCell(index: 0),
                GreenCell(index: 1),
                RedCell(index: 2),
                RedCell(index: 3),
                GreenCell(index: 4),
                RedCell(index: 5),
                GreenCell(index: 6),
                RedCell(index: 7),
                GreenCell(index: 8),
                RedCell(index: 9),
                GreenCell(index: 10),
                RedCell(index: 11),
            ]
        } else {
            data = [
                GreenCell(index: 1),
                RedCell(index: 2),
                RedCell(index: 3),
                GreenCell(index: 4),
                RedCell(index: 5),
                GreenCell(index: 6),
                RedCell(index: 7),
                GreenCell(index: 8),
                RedCell(index: 9),
                GreenCell(index: 10),
                RedCell(index: 11),
                RedCell(index: 12),
            ]
        }
        
        model = data

        counter += 1
    }
}

struct GreenCell: DiffableHashableType {
    let index: Int

    var identity: Int {
        return hashValue
    }
}

struct RedCell: DiffableHashableType {
    let index: Int

    var identity: Int {
        return hashValue
    }
}
