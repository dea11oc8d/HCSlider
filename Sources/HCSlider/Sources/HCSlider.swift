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
    
    /// The thumbs' values
    public var values: [String: Float] { _thumbs.reduce(into: [String: Float](), { $0[$1.id] = $1.value }) }
    
    /// A Boolean value that determines whether user can add new thumbs by tapping on the view.
    /// The default value of this property is false.
    //    public var isUserExtendedInteractionEnabled = false {
    //        didSet {
    //            if isUserExtendedInteractionEnabled { addGestureRecognizer(tapGestureRecognizer) }
    //            else { removeGestureRecognizer(tapGestureRecognizer) }
    //        }
    //    }
    
    /// A Boolean value that determines are value change events generated any time the value changes due to dragging.
    ///  The default value of this property is false.
    public var isContinuous = false
    
    /// A Boolean value that determines can the thumbs cross each other.
    public var canThumbsCross = true
    
    /// Max number of thumbs that can be added.
    public var maxThumbs: Int?
    
    /// Points on the track that the thumbs tend to reach.
    public var snaps = [Float]() {
        didSet {
            snaps.sort(by: { $0 < $1 })
        }
    }
    
    /// Color of the slider's track.
    public var trackColor: UIColor {
        get {
            track.color
        }
        set {
            track.color = newValue
        }
    }
    
    // MARK: - Internal properties
    
    lazy var _thumbs = [HCThumb]()
    
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
            $0.subtrack.frame = subtrackFrame(forThumbFrame: $0.frame)
        }
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let thumbFrames = _thumbs.map { thumb in
            CGRect(
                x: thumb.frame.midX - 20,
                y: thumb.frame.midY - 20,
                width: 40,
                height: 40)
        }
        if let thumbFrameIndex = thumbFrames.firstIndex(where: { $0.contains(point) }) {
            return _thumbs[thumbFrameIndex]
        } else {
            return super.hitTest(point, with: event)
        }
    }
    
    // MARK: - Public methods
    
    public func addThumb(
        id: String? = nil,
        value: Float,
        color: UIColor = .thumbColor,
        subtrackColor: UIColor = .subtrackColor) {
            
            guard _thumbs.count < maxThumbs ?? Int.max else { return }
            let thumb = HCThumb()
            if let id { thumb.id = id }
            thumb.value = value
            thumb.color = color
            thumb.subtrackColor = subtrackColor
            _thumbs.append(thumb)
            addSubview(thumb.subtrack)
            addSubview(thumb)
            thumb.frame = thumbFrame(for: thumb.value)
            thumb.subtrack.frame = subtrackFrame(forThumbFrame: thumb.frame)
            repositionLayers()
        }
    
    public func removeThumb(id: String) {
        guard let thumbIndex = _thumbs.firstIndex(where: { $0.id == id }) else { return }
        let thumb = _thumbs.remove(at: thumbIndex)
        thumb.subtrack.removeFromSuperview()
        thumb.removeFromSuperview()
    }
    
    public func setValue(_ value: Float, forThumbWithId id: String, animated: Bool) {
        guard let thumb = _thumbs.first(where: { $0.id == id }) else { return }
        if !snaps.isEmpty {
            thumb.value = snaps.nearestValue(to: value, in: 0..<snaps.count)
        } else {
            thumb.value = value
        }
        let thumbNewFrame = thumbFrame(for: thumb.value)
        let subtrackNewFrame = subtrackFrame(forThumbFrame: thumbNewFrame)
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    thumb.transform = CGAffineTransform(
                        translationX: thumbNewFrame.midX - thumb.frame.midX,
                        y: .zero)
                    thumb.subtrack.transform = CGAffineTransform(
                        scaleX: subtrackNewFrame.midX / thumb.subtrack.frame.midX,
                        y: 1)
                })
        } else {
            thumb.frame = thumbNewFrame
            thumb.subtrack.frame = subtrackNewFrame
        }
        repositionLayers()
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
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        addThumb(at: point)
    }
    
    private func addThumb(at point: CGPoint) {
        guard _thumbs.count < maxThumbs ?? Int.max else { return }
        let thumb = HCThumb()
        _thumbs.append(thumb)
        addSubview(thumb.subtrack)
        addSubview(thumb)
        thumb.frame = thumbFrame(for: point)
        thumb.subtrack.frame = subtrackFrame(forThumbFrame: thumb.frame)
        thumb.value = calculateThumbValue(with: thumb.frame.midX)
    }
    
    @objc private func panned(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began: movableThumb = _thumbs.filter { $0.frame.contains(point) }.first
        case .changed:
            guard let movableThumb else { break }
            moveThumb(movableThumb, to: point)
            if isContinuous { sendActions(for: .valueChanged) }
        case .ended:
            guard let movableThumb else { break }
            tryToSetValueToNearest(of: movableThumb)
            self.movableThumb = nil
            sendActions(for: .valueChanged)
        case .possible, .cancelled, .failed, .recognized: break
        @unknown default: break
        }
    }
    
    private func moveThumb(_ thumb: HCThumb, to point: CGPoint) {
        if canThumbsCross {
            thumb.frame = thumbFrame(for: point.clampX(track.frame.minX, track.frame.maxX))
        } else {
            if
            let leftThumb = _thumbs.last(where: { $0.value < thumb.value }),
            let rightThumb = _thumbs.first(where: { $0.value > thumb.value }) {
                
                let leftPoint = max(track.frame.minX, leftThumb.frame.midX)
                let rightPoint = min(track.frame.maxX, rightThumb.frame.midX)
                thumb.frame = thumbFrame(for: point.clampX(leftPoint, rightPoint))
            } else {
                thumb.frame = thumbFrame(for: point.clampX(track.frame.minX, track.frame.maxX))
            }
        }
        thumb.value = calculateThumbValue(with: thumb.frame.midX)
        thumb.subtrack.frame = subtrackFrame(forThumbFrame: thumb.frame)
        repositionLayers()
    }
    
    private func thumbFrame(for point: CGPoint) -> CGRect {
        CGRect(
            x: point.x - Constants.thumbSide.half,
            y: track.frame.midY - Constants.thumbSide.half,
            width: Constants.thumbSide,
            height: Constants.thumbSide)
    }
    
    private func subtrackFrame(forThumbFrame frame: CGRect) -> CGRect {
        CGRect(
            x: track.frame.minX,
            y: track.frame.minY,
            width: frame.midX - track.frame.minX,
            height: Constants.trackHeight)
    }
    
    private func calculateThumbValue(with x: CGFloat) -> Float {
        let width = x - track.frame.minX
        let fullWidth = track.frame.maxX - track.frame.minX
        return Float(width / fullWidth)
    }
    
    private func tryToSetValueToNearest(of thumb: HCThumb) {
        guard !snaps.isEmpty else { return }
        thumb.value = snaps.nearestValue(to: thumb.value, in: 0..<snaps.count)
        thumb.frame = thumbFrame(for: thumb.value)
        thumb.subtrack.frame = subtrackFrame(forThumbFrame: thumb.frame)
        repositionLayers()
    }
    
    private func repositionLayers() {
        var subtrackFirstPosition: CGFloat = 0
        var thumbFirstPosition: CGFloat = CGFloat(_thumbs.count)
        _thumbs.sorted { $0.value < $1.value }.forEach {
            $0.subtrack.layer.zPosition = subtrackFirstPosition
            subtrackFirstPosition += 1
            $0.layer.zPosition = thumbFirstPosition
            thumbFirstPosition += 1
        }
    }
    
    private func setUpView() {
        addSubview(track)
        addGestureRecognizer(swipeGestureRecognizer)
    }
}
