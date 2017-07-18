
//
//  AMap+LXExtension.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/14.
//  Copyright © 2017年 从今以后. All rights reserved.
//

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

	static func polyline(with coordinates: [CLLocationCoordinate2D]) -> Base {
		var _coordinates = coordinates
		return Base(coordinates: &_coordinates, count: UInt(coordinates.count))
	}
}

extension Swifty where Base: AMapGeoPoint {

	static func location(with coordinate: CLLocationCoordinate2D) -> AMapGeoPoint {
		return Base.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
	}
}
