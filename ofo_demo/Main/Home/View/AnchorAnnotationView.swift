//
//  AnchorAnnotationView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/17.
//  Copyright © 2017年 从今以后. All rights reserved.
//

class AnchorAnnotationCalloutView: UIView {

	let width: CGFloat = 100
	let height: CGFloat = 36
	let arrowHeight: CGFloat = 4
	let arrowSpacing: CGFloat = 2

	let text = NSAttributedString(string: "请就近寻车", attributes: [.font: UIFont.systemFont(ofSize: 14)])

	lazy var textRect: CGRect = {
		let size = LXSizeCeil(text.size())
		let rect = CGRect(origin: CGPoint(x: (width - size.width)/2, y: (height - arrowHeight - arrowSpacing - size.height)/2), size: size).integral
		return rect
	}()

	lazy var shadowPath: CGPath = {
		let diameter = height - arrowHeight - arrowSpacing
		let radius = diameter / 2

		let path = CGMutablePath()

		path.move(to: CGPoint(x: radius, y: 0))
		path.addLine(to: CGPoint(x: width - radius, y: 0))
		path.addArc(center: CGPoint(x: width - radius, y: radius), radius: radius, startAngle: -.pi/2, endAngle: .pi/2, clockwise: false)

		path.addLine(to: CGPoint(x: width/2 + arrowHeight, y: diameter))
		path.addLine(to: CGPoint(x: width/2, y: diameter + arrowHeight))
		path.addLine(to: CGPoint(x: width/2 - arrowHeight, y: diameter))

		path.addLine(to: CGPoint(x: radius, y: diameter))
		path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .pi/2, endAngle: .pi/2*3, clockwise: false)

		return path
	}()

	init() {
		super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
		backgroundColor = .clear
		layer.shadowOpacity = 0.1
		layer.shadowPath = shadowPath
		layer.shadowOffset = CGSize(width: 0, height: 3)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
		context?.addPath(shadowPath)
		context?.fillPath()
		text.draw(in: textRect)
	}
}

class AnchorAnnotationView: MAAnnotationView {

	var showCallout = false {
		didSet {
			isSelected = showCallout
		}
	}
	private let dotLayer: CALayer
	private var isStopBreathing = false

	override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
		dotLayer = CALayer()
		dotLayer.cornerRadius = 3
		dotLayer.position = CGPoint(x: 12, y: 12)
		dotLayer.bounds = CGRect(x: 0, y: 0, width: 6, height: 6)
		dotLayer.backgroundColor = UIColor(hex: 0xffd900).cgColor

		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		layer.addSublayer(dotLayer)

		image = #imageLiteral(resourceName: "homePage_wholeAnchor")
		centerOffset.y = -image.size.height / 2 + 2 // 微调 2 点效果更好
		isEnabled = false
		canShowCallout = true
		customCalloutView = MACustomCalloutView(customView: AnchorAnnotationCalloutView())
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - 构造方法
extension AnchorAnnotationView {

	class func annotationView(with mapView: MAMapView, for annotation: AnchorAnnotation) -> AnchorAnnotationView {
		let annotationView: AnchorAnnotationView
		let reuseIdentifier = String(reflecting: self)
		if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? AnchorAnnotationView {
			annotationView = _annotationView
		} else {
			annotationView = AnchorAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
		}
		return annotationView
	}
}

// MARK: - 动画效果
extension AnchorAnnotationView {

	func performBounceAnimation() {
		guard layer.animation(forKey: "bounce") == nil else { return }
		let bounceAnimation = CAKeyframeAnimation(keyPath: "position.y")
		bounceAnimation.duration = 0.25
		bounceAnimation.isAdditive = true
		bounceAnimation.values = [0, -20, 0]
		bounceAnimation.timingFunctions = [.easeOut, .easeIn]
		layer.add(bounceAnimation, forKey: "bounce")
	}

	func startBreathingAnimation() {
		guard dotLayer.animation(forKey: "breathing") == nil else { return }
		let breathingAnimation = CABasicAnimation(keyPath: "transform")
		breathingAnimation.duration = 1.5
		breathingAnimation.autoreverses = true
		breathingAnimation.repeatCount = .infinity
		breathingAnimation.timingFunction = .linear
		breathingAnimation.toValue = CATransform3DMakeScale(2.5, 2.5, 1)
		dotLayer.add(breathingAnimation, forKey: "breathing")
	}

	func stopBreathingAnimation() {
		guard dotLayer.animation(forKey: "breathing") != nil else { return }
		let animation = CABasicAnimation(keyPath: "transform")
		animation.fromValue = dotLayer.presentation()?.transform
		animation.timingFunction = .linear
		animation.duration = 0.25
		dotLayer.add(animation, forKey: nil)
		dotLayer.removeAnimation(forKey: "breathing")
	}
}
