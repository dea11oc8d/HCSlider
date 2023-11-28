//
//  HCThumb.swift
//  HCSlider
// 
//  Created by 0x01EAC5 on 26.11.2023.

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

import UIKit

// MARK: - HCThumbCustomizable

public protocol HCThumbCustomizable {
    var id: String { get set }
    var value: Float { get set }
    var thumbColor: UIColor { get set }
    var subtrackColor: UIColor { get set }
}

// MARK: - HCThumb

final class HCThumb: HCColoredView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let side: CGFloat = 28
    }
    
    // MARK: - Public properties
    
    var subtrack: HCSubtrack
    
    // MARK: - Private properties
    
    private var _id: String
    private var _value: Float = 0.0

    // MARK: - Initializers
    
    init(id: String = UUID().uuidString) {
        self._id = id
        self.subtrack = HCSubtrack()
        super.init(frame: CGRect(x: .zero, y: .zero, width: Constants.side, height: Constants.side), color: .thumbColor)
        
    }
    
    // MARK: - HCColoredView
    
    override func setUpView() {
        super.setUpView()
        
        layer.cornerRadius = Constants.side.half
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: .zero, height: 6)
        layer.shadowRadius = 13
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

// MARK: - HCThumbCustomizable

extension HCThumb: HCThumbCustomizable {
    var id: String { get { _id } set { _id = newValue } }
    var value: Float { get { _value } set { _value = newValue } }
    var thumbColor: UIColor { get { color } set { color = newValue } }
    var subtrackColor: UIColor { get { subtrack.color } set { subtrack.color = newValue } }
}

