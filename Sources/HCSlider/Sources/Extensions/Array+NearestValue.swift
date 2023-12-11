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

import Foundation

extension Array where Element: SignedNumeric, Element: Comparable {
    
    func nearestValue(to value: Element, in range: Range<Int>) -> Element {
        let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
        
        if midIndex == range.lowerBound {
            let leftDifference = abs(value - self[range.lowerBound])
            let rightDifference = abs(value - self[range.upperBound])
            return leftDifference <= rightDifference ? self[range.lowerBound] : self[range.upperBound]
        }
        
        if value < self[midIndex] {
            return nearestValue(to: value, in: range.lowerBound..<midIndex)
        } else if value > self[midIndex] {
            return nearestValue(to: value, in: midIndex..<range.upperBound)
        } else {
            return self[midIndex]
        }
    }
}
