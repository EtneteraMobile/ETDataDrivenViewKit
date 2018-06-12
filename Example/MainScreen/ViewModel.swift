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

    func loadData() {
        let participants = TableSection(header: HeaderFooter(text: "First section"), rows: [
            GreenRow(text: "1\twith calculated height dimension\n\tsecond line\n\tthird line\n\tfourth\n\tfifth"),
            YellowRow(text: "2\twith automatic height dimension\n\tsecond line"),
            GreenRow(text: "3\twith calculated height dimension\n\tsecond line"),
            YellowRow(text: "4\twith automatic height dimension\n\tsecond line"),
            GreenRow(text: "5\twith calculated height dimension\n\tsecond line"),
            YellowRow(text: "6\twith automatic height dimension\n\tsecond line"),
            GreenRow(text: "7\twith calculated height dimension\n\tsecond line"),
            YellowRow(text: "8\twith automatic height dimension\n\tsecond line"),
            GreenRow(text: "9\twith calculated height dimension\n\tsecond line"),

            ], footer: HeaderFooter(text: "First footer"))

        let mentors = TableSection(header: HeaderFooter(text: "Second section"), rows: [
            GreenRow(text: "1\twith calculated height dimension\n\tsecond line"),
            YellowRow(text: "2\twith automatic height dimension\n\tsecond line"),
            GreenRow(text: "3\twith calculated height dimension\n\tsecond line"),
            YellowRow(text: "4\twith automatic height dimension\n\tsecond line"),
            ], footer: HeaderFooter(text: "Second footer"))
        model = [participants, mentors]
    }
}
