//
//  MapSearchor.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/20.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class MapSearchor {

	let searchAPI: AMapSearchAPI

	init() {
		searchAPI = AMapSearchAPI()!
	}
}

extension MapSearchor {

	func performPOIAroundSearch(for center: CLLocationCoordinate2D) {
		let request = AMapPOIAroundSearchRequest()
		request.radius = 200
		request.types = "餐饮服务"
		request.location = AMapGeoPoint.lx.location(with: center)
		searchAPI.aMapPOIAroundSearch(request)
	}

	func performWalkingRouteSearch(for origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
		let origin = AMapGeoPoint.lx.location(with: origin)
		let destination = AMapGeoPoint.lx.location(with: destination)

		let request = AMapWalkingRouteSearchRequest()
		request.origin = origin
		request.destination = destination

		searchAPI.aMapWalkingRouteSearch(request)
	}
}
