//
//  NearbyBikeAnnotationView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/7.
//  Copyright © 2017年 从今以后. All rights reserved.
//

class NearbyBikeAnnotationView: MAAnnotationView {

	class func annotationView(with mapView: MAMapView, for annotation: MAAnnotation) -> NearbyBikeAnnotationView {
		let annotationView: NearbyBikeAnnotationView
		let reuseIdentifier = String(reflecting: self)
		if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? NearbyBikeAnnotationView {
			annotationView = _annotationView
		} else {
			annotationView = NearbyBikeAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			annotationView.image = #imageLiteral(resourceName: "HomePage_nearbyBike")
		}
		return annotationView
	}

	override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		if newSuperview != nil {
			transform = CGAffineTransform(scaleX: 0, y: 0)
			UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
				self.transform = .identity
			}, completion: nil)
		}
	}
}
