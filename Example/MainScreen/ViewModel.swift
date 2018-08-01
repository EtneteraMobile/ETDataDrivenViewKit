//
//  ViewModel.swift
//  example
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import ETDataDrivenViewKit

protocol ViewModelType: class {
    typealias Model = [TableSection]

    var model: Model { get }
    var didUpdateModel: ((Model) -> Void)? { get set }
    func loadData()
}

class ViewModel: ViewModelType {
    private(set) var model: [TableSection] = [] {
        didSet {
            didUpdateModel?(model)
        }
    }
    var didUpdateModel: ((Model) -> Void)?

    typealias GreenRow = ViewController.GreenCellFactory.Content
    typealias YellowRow = ViewController.YellowCellFactory.Content

    func loadData() {
        if model.isEmpty || model.count == 1 {
            let participants = TableSection(identity: "Participants", rows: [
                GreenRow(text: "1\twith calculated height dimension\n\tsecond line\n\tthird line\n\tfourth\n\tfifth"),
                YellowRow(text: "2\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "3\twith calculated height dimension\n\tsecond line"),
                YellowRow(text: "4\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "5\twith calculated height dimension\n\tsecond line"),
                YellowRow(text: "6\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "7\twith calculated height dimension\n\tsecond line"),
                YellowRow(text: "8\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "9\twith calculated height dimension\n\tsecond line"),
                ])

            let mentors = TableSection(identity: "Mentors", rows: [
                GreenRow(text: "2.1\twith calculated height dimension\n\tsecond line"),
                YellowRow(text: "2.2\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "2.3\twith calculated height dimension\n\tsecond line"),
                YellowRow(text: "2.4\twith automatic height dimension\n\tsecond line"),
                ])
            model = [participants, mentors]
        } else {
            let participants = TableSection(identity: "Participants", rows: [
                GreenRow(text: "1\twith calculated height dimension\n\tsecond line\n\tthird line\n\tfourth\n\tfifth"),
                YellowRow(text: "4\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "5\twith calculated height dimension\n\tsecond line"),
                GreenRow(text: "7\twith calculated height dimension\n\tsecond line"),
                YellowRow(text: "6\twith automatic height dimension\n\tsecond line"),
                YellowRow(text: "8\twith automatic height dimension\n\tsecond line"),
                GreenRow(text: "9\twith calculated height dimension\n\tsecond line"),
                GreenRow(text: "10\twith calculated height dimension\n\tsecond line"),
                ])
            model = [participants]
        }
    }
}
