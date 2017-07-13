
//
//  MAPolyline+LXExtension.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/14.
//  Copyright © 2017年 从今以后. All rights reserved.
//

extension Swifty where Base == MAPolyline.Type {

	func polyline(with coordinates: [CLLocationCoordinate2D]) -> MAPolyline {
		var _coordinates = coordinates
		return base.init(coordinates: &_coordinates, count: UInt(coordinates.count))
	}
}

extension Swifty where Base: MAPolyline {
	
	var firstCoordinate: CLLocationCoordinate2D {
		var coordinate = CLLocationCoordinate2D()
		base.getCoordinates(&coordinate, range: NSRange(location: 0, length: 1))
		return coordinate
	}

	var lastCoordinate: CLLocationCoordinate2D {
		var coordinate = CLLocationCoordinate2D()
		base.getCoordinates(&coordinate, range: NSRange(location: Int(base.pointCount) - 1, length: 1))
		return coordinate
	}
}
