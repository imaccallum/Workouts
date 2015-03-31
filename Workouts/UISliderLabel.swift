//
//  UISliderLabel.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/22/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import UIKit

protocol UISliderLabelDelegate {
    func sliderLabel(sliderLabel: UISliderLabel, didChangeValue value: CGFloat)
    func sliderLabel(sliderLabel: UISliderLabel, formatForValue value: CGFloat) -> String?
    func sliderLabel(minValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat?
    func sliderLabel(maxValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat?
    func sliderLabel(deviationValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat?
    func sliderLabel(incrementByValueForSliderLabel sliderLabel: UISliderLabel) -> CGFloat?
}

class UISliderLabel: UILabel {
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var startX: CGFloat!
    private var startValue: CGFloat!
    
    var delegate: UISliderLabelDelegate? {
        didSet {
            min = delegate?.sliderLabel(minValueForSliderLabel: self) ?? 0
            max = delegate?.sliderLabel(maxValueForSliderLabel: self) ?? 1000
            deviation = delegate?.sliderLabel(deviationValueForSliderLabel: self) ?? 1
            increment = delegate?.sliderLabel(incrementByValueForSliderLabel: self) ?? 1
        }
    }
    var  d: NSNumber?
    var value: CGFloat = 0 {
        didSet {
            self.text = delegate?.sliderLabel(self, formatForValue: value) ?? "\(value)"
            if value != oldValue {
                delegate?.sliderLabel(self, didChangeValue: value)
            }
        }
    }
    
    var min: CGFloat = 0
    var max: CGFloat = 1000
    var deviation: CGFloat = 10
    var increment: CGFloat = 1
    
    override init() {
        super.init()
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleGestureRecognizer:")
        addGestureRecognizer(panGestureRecognizer)
        userInteractionEnabled = true
    }
    
    func handleGestureRecognizer(sender: UIPanGestureRecognizer) {
    
        switch sender.state {
        case .Began:
            startX = sender.locationInView(self).x
            startValue = value
        case .Changed:
            let d = startValue + (floor((sender.locationInView(self).x - startX) / deviation) * increment)
            if min <= d && d <= max {
                value = d
            }
        default:
            break
        }
    }
}
