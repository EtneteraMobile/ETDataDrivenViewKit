//
//  ViewModel.swift
//  example
//
//  Created by Jan Čislinský on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s. All rights reserved.
//

import Foundation
import ETDataDrivenViewKit

protocol TableViewModelType: class {
    typealias Model = [SectionModel]

    var model: Model { get }
    var didUpdateModel: ((Model) -> Void)? { get set }
    func loadData()
}

class TableViewModel: TableViewModelType {
    private(set) var model: [SectionModel] = [] {
        didSet {
            didUpdateModel?(model)
        }
    }
    var didUpdateModel: ((Model) -> Void)?

    typealias HeaderFooter = TableViewController.HeaderFooterFactory.HeaderFooter
    typealias GreenRow = TableViewController.GreenCellFactory.Content
    typealias YellowRow = TableViewController.YellowCellFactory.Content

    func loadData() {
        if model.isEmpty || model.count == 1 {
            let participants = SectionModel(identity: "Participants", header: HeaderFooter(id: "section1", text: "First section header"), rows: [
                GreenRow(id: "green1", text: "1\twith calculated height dimension\n\tsecond line\n\tthird line\n\tfourth\n\tfifth"),
                YellowRow(id: "yellow1", text: "2\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green2", text: "3\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow2", text: "4\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green3", text: "5\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow3", text: "6\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green4", text: "7\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow4", text: "8\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green5", text: "9\twith calculated height dimension\n\tsecond line"),
                ])

            let mentors = SectionModel(identity: "Mentors", rows: [
                GreenRow(id: "green2.1", text: "2.1\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow2.1", text: "2.2\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green2.2", text: "2.3\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow2.2", text: "2.4\twith automatic height dimension\n\tsecond line"),
                ])
            model = [participants, mentors]
        } else {
            let participants = SectionModel(identity: "Participants", header: HeaderFooter(id: "section1header", text: "First section header\nwith second line"), rows: [
                GreenRow(id: "green1", text: "1\twith calculated height dimension\n\tsecond line\n\tthird line\n\tfourth\n\tfifth\n\treloadded haha"),
                YellowRow(id: "yellow1", text: "2\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green3", text: "5\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow2", text: "4\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green4", text: "7\twith calculated height dimension\n\tsecond line"),
                YellowRow(id: "yellow3", text: "6\twith automatic height dimension\n\tsecond line"),
                GreenRow(id: "green5", text: "9\twith calculated height dimension\n\tsecond line"),
                ], footer: HeaderFooter(id: "section1footer", text: "First section footer"))
            model = [participants]
        }
    }
}
