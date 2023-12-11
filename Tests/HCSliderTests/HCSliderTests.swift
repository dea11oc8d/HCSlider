//
//  Array+NearestValue.swift
//  HCSlider
//
//  Created by 0x01EAC5 on 11.12.2023.

//  Copyright (c) 2023 0x01EAC5

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import HCSlider

final class HCSliderTests: XCTestCase {
    
    var slider: HCSlider!
    var firstValue: Float!
    var secondValue: Float!
    
    override func setUpWithError() throws {
        slider = HCSlider()
        slider.frame = CGRect(x: .zero, y: .zero, width: 128, height: 20)
        slider.addThumb(id: "1", value: 0.2)
        slider.addThumb(id: "2", value: 0.85)
        slider.layoutSubviews()
    }
    
    override func tearDownWithError() throws {
        slider = nil
    }
    
    func testThumbFrameComplianceWithTheValue() {
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1" })?.frame.minX.rounded(), 20)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "2" })?.frame.minX.rounded(), 85)
    }
    
    func testZLayers() {
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1"})?.layer.zPosition, 3)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "2"})?.layer.zPosition, 2)
    }
    
    func testAddThumb() {
        slider.addThumb(id: "3", value: 1.0)
        XCTAssertEqual(slider._thumbs.count, 3)
        XCTAssertNotNil(slider._thumbs.first(where: { $0.id == "3"}))
    }
    
    func testRepositionLayers() {
        slider.addThumb(id: "3", value: 0.6)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1"})?.layer.zPosition, 5)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "2"})?.layer.zPosition, 3)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "3"})?.layer.zPosition, 4)
    }
    
    func testRemoveThumb() {
        slider.removeThumb(id: "2")
        XCTAssertEqual(slider._thumbs.count, 1)
        XCTAssertEqual(slider._thumbs.first?.id, "1")
    }
    
    func testSetThumbValue() {
        slider.setValue(0.5, forThumbWithId: "1", animated: false)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1" })?.frame.minX.rounded(), 50)
    }
    
    func testSetThumbValueAnimated() {
        slider.setValue(0.5, forThumbWithId: "1", animated: true)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1" })?.frame.minX.rounded(), 50)
    }
    
    func testSetThumbValueWithPivots() {
        slider.snaps = [0.45, 0.55, 1.0]
        slider.setValue(0.5, forThumbWithId: "1", animated: false)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1" })?.frame.minX.rounded(), 45)
    }
    
    func testSetThumbValueWithPivotsAnimated() {
        slider.snaps = [0.45, 0.55, 1.0]
        slider.setValue(0.5, forThumbWithId: "1", animated: true)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1" })?.frame.minX.rounded(), 45)
    }
}
