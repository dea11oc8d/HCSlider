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
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "1"})?.layer.zPosition, 3)
        XCTAssertEqual(slider._thumbs.first(where: { $0.id == "2"})?.layer.zPosition, 2)
    }
    
    func testRemoveThumb() {
        slider.removeThumb(id: "2")
        XCTAssertEqual(slider._thumbs.count, 1)
        XCTAssertEqual(slider._thumbs.first?.id, "1")
    }
    
    func testChangeMinValue() {
        slider.minValue = 0.5
        XCTAssertEqual(slider.values["1"], 0.1)
        XCTAssertEqual(slider.values["2"], 0.425)
    }
    
    func testChangeMaxValue() {
        slider.maxValue = 2.0
        XCTAssertEqual(slider.values["1"], 0.4)
        XCTAssertEqual(slider.values["2"], 1.7)
    }
    
    func testChangeMinAndMaxValues() {
        slider.minValue = 4.5
        slider.maxValue = 9.5
        XCTAssertEqual(slider.values["1"], 1.0)
        XCTAssertEqual(slider.values["2"], 4.25)
    }
}
