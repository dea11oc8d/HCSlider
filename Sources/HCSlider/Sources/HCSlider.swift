//
//  HCSlider.swift
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

public class HCSlider: UIControl {
    
    // MARK: - Constants
    
    private enum Constants {
        static let trackHeight: CGFloat = 4
        static let thumbSide: CGFloat = 28
    }
    
    // MARK: - Public properties
    
    public var values: [String: Float] { _thumbs.reduce(into: [String: Float](), { $0[$1.id] = $1.value })}
    
    /// A Boolean value that determines whether user can add new thumbs by tapping on the view. 
    /// The default value of this property is false.
    //    public var isUserExtendedInteractionEnabled = false {
    //        didSet {
    //            if isUserExtendedInteractionEnabled { addGestureRecognizer(tapGestureRecognizer) }
    //            else { removeGestureRecognizer(tapGestureRecognizer) }
    //        }
    //    }
    
    /// Minimum value of the slider.
    public var minValue: Float = 0.0 {
        didSet {
            _thumbs.forEach { $0.value = calculateThumbValue(with: $0.frame.midX) }
        }
    }
    
    /// Maximum value of the slider.
    public var maxValue: Float = 1.0 {
        didSet {
            _thumbs.forEach { $0.value = calculateThumbValue(with: $0.frame.midX) }
        }
    }
    
    /// Max number of thumbs that can be added.
    public var maxThumbs: Int?
    
    /// A Boolean value that determines are value change events generated any time the value changes due to dragging.
    /// The default value of this property is false.
    public var isContinuous = false
    
    /// Color of the slider's track.
    public var trackColor: UIColor {
        get {
            track.color
        }
        set {
            track.color = newValue
        }
    }
    
    lazy var _thumbs = Set<HCThumb>()
    
    // MARK: - Private properties
    
    private lazy var track = HCTrack()
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
    private lazy var swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
    
    
    private var movableThumb: HCThumb?
    private var movableThumbFrame: CGRect?
    
    // MARK: - Initializers
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setUpView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        track.frame = CGRect(
            x: self.bounds.minX + Constants.thumbSide.half,
            y: self.bounds.midY - Constants.trackHeight.half,
            width: self.bounds.maxX - self.bounds.minX - Constants.thumbSide,
            height: Constants.trackHeight)
        _thumbs.forEach {
            $0.frame = thumbFrame(for: $0.value)
            $0.subtrack.frame = subtrackFrame(forThumb: $0)
        }
    }
    
    // MARK: - Public methods
    
    public func addThumb(id: String? = nil, value: Float, color: UIColor = .thumbColor, subtrackColor: UIColor = .subtrackColor) {
        guard _thumbs.count < maxThumbs ?? Int.max else { return }
        let thumb = HCThumb()
        if let id { thumb.id = id }
        thumb.value = value
        thumb.color = color
        thumb.subtrackColor = subtrackColor
        _thumbs.insert(thumb)
        addSubview(thumb.subtrack)
        addSubview(thumb)
        thumb.frame = thumbFrame(for: thumb.value)
        thumb.subtrack.frame = subtrackFrame(forThumb: thumb)
        repositionLayers()
    }
    
    public func removeThumb(id: String) {
        guard let thumbIndex = _thumbs.firstIndex(where: { $0.id == id }) else { return }
        let thumb = _thumbs.remove(at: thumbIndex)
        thumb.subtrack.removeFromSuperview()
        thumb.removeFromSuperview()
    }
    
    // MARK: - Private methods
    
    private func thumbFrame(for value: Float) -> CGRect {
        let fullWidth = track.frame.maxX - track.frame.minX
        return CGRect(
            x: track.frame.minX + CGFloat(value) * fullWidth - Constants.thumbSide.half,
            y: track.frame.midY - Constants.thumbSide.half,
            width: Constants.thumbSide,
            height: Constants.thumbSide)
    }
    
    private func repositionLayers() {
        var subtrackFirstPosition: CGFloat = 0
        var thumbFirstPosition: CGFloat = CGFloat(_thumbs.count)
        _thumbs.sorted(by: { $0.value > $1.value }).forEach {
            $0.subtrack.layer.zPosition = subtrackFirstPosition
            subtrackFirstPosition += 1
            $0.layer.zPosition = thumbFirstPosition
            thumbFirstPosition += 1
        }
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        addThumb(at: point)
    }
    
    private func addThumb(at point: CGPoint) {
        guard _thumbs.count < maxThumbs ?? Int.max else { return }
        let thumb = HCThumb()
        _thumbs.insert(thumb)
        addSubview(thumb.subtrack)
        addSubview(thumb)
        thumb.frame = thumbFrame(for: point)
        thumb.subtrack.frame = subtrackFrame(forThumb: thumb)
        thumb.value = calculateThumbValue(with: thumb.frame.midX)
    }
    
    @objc private func panned(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began: movableThumb = _thumbs.filter { $0.frame.contains(point) }.first
        case .changed:
            guard movableThumb != nil else { break }
            moveThumb(to: point)
            if isContinuous { sendActions(for: .valueChanged) }
        case .ended:
            guard movableThumb != nil else { break }
            self.movableThumb = nil
            sendActions(for: .valueChanged)
        case .possible, .cancelled, .failed, .recognized: break
        @unknown default: break
        }
    }
    
    private func moveThumb(to point: CGPoint) {
        guard let movableThumb else { return }
        movableThumb.frame = thumbFrame(for: point.clampX(track.frame.minX, track.frame.maxX))
        movableThumb.subtrack.frame = subtrackFrame(forThumb: movableThumb)
        movableThumb.value = calculateThumbValue(with: movableThumb.frame.midX)
        repositionLayers()
    }
    
    private func thumbFrame(for point: CGPoint) -> CGRect {
        CGRect(
            x: point.x - Constants.thumbSide.half,
            y: track.frame.midY - Constants.thumbSide.half,
            width: Constants.thumbSide,
            height: Constants.thumbSide)
    }
    
    private func subtrackFrame(forThumb thumb: HCThumb) -> CGRect {
        CGRect(
            x: track.frame.minX,
            y: track.frame.minY,
            width: thumb.frame.midX - track.frame.minX,
            height: Constants.trackHeight)
    }
    
    private func calculateThumbValue(with x: CGFloat) -> Float {
        let width = x - track.frame.minX
        let fullWidth = track.frame.maxX - track.frame.minX
        let rawValue = Float(width / fullWidth)
        switch rawValue {
        case .zero: return minValue
        default: return rawValue * (maxValue - minValue)
        }
    }
    
    private func setUpView() {
        addSubview(track)
        addGestureRecognizer(swipeGestureRecognizer)
    }
}
