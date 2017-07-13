//
//  NavigationRoute.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/14.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import Foundation

class NavigationRoute {

	private(set) var routePolyline: MAPolyline

	init(path: AMapPath, startCoordinate: CLLocationCoordinate2D, endCoordinate: CLLocationCoordinate2D) {
		var coordinates = path.steps.flatMap { step -> [CLLocationCoordinate2D] in
			return step.polyline.components(separatedBy: ";").map { (string: String) -> CLLocationCoordinate2D in
				let degreesList = string.components(separatedBy: ",")
				return CLLocationCoordinate2D(latitude: Double(degreesList[1])!, longitude: Double(degreesList[0])!)
			}
		}
		coordinates.insert(startCoordinate, at: 0)
		coordinates.append(endCoordinate)
		routePolyline = MAPolyline.lx.polyline(with: coordinates)
	}
}

extension NavigationRoute {

	func add(to mapView: MAMapView) {
		mapView.add(routePolyline)
	}

	func remove(from mapView: MAMapView) {
		mapView.remove(routePolyline)
	}
}
