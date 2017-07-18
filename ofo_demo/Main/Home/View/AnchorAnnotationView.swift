//
//  AnchorAnnotationView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/17.
//  Copyright © 2017年 从今以后. All rights reserved.
//

class AnchorAnnotationView: MAAnnotationView {

	class func annotationView(with mapView: MAMapView, for annotation: AnchorAnnotation) -> AnchorAnnotationView {
		let annotationView: AnchorAnnotationView
		let reuseIdentifier = String(reflecting: self)
		if let _annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? AnchorAnnotationView {
			annotationView = _annotationView
		} else {
			annotationView = AnchorAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
			annotationView.image = #imageLiteral(resourceName: "homePage_wholeAnchor")
			annotationView.centerOffset.y = -annotationView.image.size.height / 2 + 2 // 微调 2 点效果更好
		}
		return annotationView
	}
}

extension AnchorAnnotationView {

	func performBounceAnimation() {
		UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
			self.lx_centerY -= 20
		}, completion: { _ in
			UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
				self.lx_centerY += 20
			}, completion: nil)
		})
	}
}
