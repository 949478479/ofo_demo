//
//  AnchorAnnotation.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/17.
//  Copyright © 2017年 从今以后. All rights reserved.
//

class AnchorAnnotation: MAPointAnnotation {

	init(coordinate: CLLocationCoordinate2D, lockedScreenPoint: CGPoint) {
		super.init()
		self.coordinate = coordinate
		self.lockedScreenPoint = lockedScreenPoint
		isLockedToScreen = true
	}
}

extension AnchorAnnotation {

	func add(to mapView: MAMapView) {
		mapView.addAnnotation(self)
	}
}
