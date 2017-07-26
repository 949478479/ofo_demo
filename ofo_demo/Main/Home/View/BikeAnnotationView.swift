//
//  BikeAnnotationView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/7.
//  Copyright © 2017年 从今以后. All rights reserved.
//

class BikeAnnotationCalloutView: UIView {}

class BikeAnnotationView: MAAnnotationView {
	
	@IBOutlet private var durationLabel: UILabel!
	@IBOutlet private var distanceLabel: UILabel!

	class func annotationView(with mapView: MAMapView, for annotation: BikeAnnotation) -> BikeAnnotationView {
		let annotationView: BikeAnnotationView
		let reuseIdentifier = String(reflecting: self)
		if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? BikeAnnotationView {
			annotationView = _annotationView
		} else {
			annotationView = BikeAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			annotationView.image = #imageLiteral(resourceName: "HomePage_nearbyBike")
			annotationView.centerOffset.y = -annotationView.image.size.height / 2 + 5 // 微调 5 点效果更好
			let calloutView = BikeAnnotationCalloutView.lx.instantiateFromNib(withOwner: annotationView, options: nil)
			annotationView.customCalloutView = MACustomCalloutView(customView: calloutView)
		}
		return annotationView
	}
}

// MARK: - 超类方法
extension BikeAnnotationView {

	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		if newSuperview != nil {
			transform = CGAffineTransform(scaleX: 0, y: 0)
			UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
				self.transform = .identity
			}, completion: nil)
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		canShowCallout = false
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// 点击地图时会取消标记的选中状态，因此关闭此属性，这样再次点击标记才能正常显示 callout
		if selected {
		} else {
			canShowCallout = false
		}

		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
			self.transform = selected ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
		}, completion: nil)
	}
}

extension BikeAnnotationView {

	func configure(with path: AMapPath) {
		let duration = String(Int(ceil(Double(path.duration)/60)))
		let attributedText = NSMutableAttributedString(string: "步行 \(duration) 分钟")
		attributedText.setAttributes([.font: UIFont.systemFont(ofSize: 10)], range: attributedText.lx.stringRange)
		attributedText.setAttributes([.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.orange], range: NSRange(location: 3, length: duration.count))
		durationLabel.attributedText = attributedText

		distanceLabel.text = "距离 \(path.distance) 米"

		// 由于 canShowCallout 选中时为 false，因此为了能显示出来，需要先取消选中再重新选中
		canShowCallout = true
		super.setSelected(false, animated: false)
		setSelected(true, animated: true)
	}
}
