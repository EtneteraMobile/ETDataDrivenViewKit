//
//  ETDataDrivenViewKitTests.swift
//  Etnetera a. s.
//
//  Created by Jan Cislinsky on 03. 04. 2018.
//  Copyright © 2018 Etnetera a. s.. All rights reserved.
//

import Foundation
import XCTest
import ETDataDrivenViewKit

struct TestClass {
    let text: String
}

class ETDataDrivenViewKitTests: XCTestCase {
    var objectsAny: [Any]!
    var objects: [TestClass]!

    override func setUp() {
        super.setUp()
        objects = []
        for i in 0..<5000000 {
            objects.append(TestClass(text: "Ahoj \(i)"))
        }
        objectsAny = objects
    }

    func testPerformance1() {
        measure {
            objects.forEach {
                let t = $0.text
            }
        }
    }

    func testPerformance2() {
        measure {
            objectsAny.forEach {
                let t = ($0 as! TestClass).text
            }
        }
    }
}
