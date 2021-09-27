//
//  TimerCirclePathView.swift
//  TimerApp
//
//  Created by Masato Takamura on 2021/09/26.
//

import UIKit

enum State {
    case invalidate
    case progress
    case pause
}

final class TimerCirclePathView: UIView {

    private lazy var progressShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 10
        shapeLayer.strokeColor = UIColor.orange.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        return shapeLayer
    }()

    private lazy var backgroundShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 20
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        //影
        shapeLayer.shadowOffset = CGSize(width:0, height:0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.gray.cgColor
        shapeLayer.shadowOpacity = 0.3
        return shapeLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .gray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCirclePath(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool = true) {
        let circlePath: UIBezierPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )

        //後ろの線の設定
        self.layer.addSublayer(backgroundShapeLayer)
        backgroundShapeLayer.path = circlePath.cgPath
        //進行線の設定
        self.layer.addSublayer(progressShapeLayer)
        progressShapeLayer.path = circlePath.cgPath
    }


    
    func startAnimation(_ duration: Double) {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.duration = duration
        progressAnimation.fromValue = 0
        progressAnimation.toValue = 1.0
        progressAnimation.fillMode = .forwards
        progressAnimation.duration = duration
        progressAnimation.isRemovedOnCompletion = false
        self.layer.speed = 1.0
        progressShapeLayer.add(progressAnimation, forKey: "progress")
    }

    func pauseAnimation() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    func resumeAnimation(){
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

    func reset() {
        layer.speed = 0
        layer.timeOffset = 0
    }
}
