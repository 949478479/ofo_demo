//
//  BikeAnnotationCollection.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/18.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class BikeAnnotation: MAPointAnnotation {}

class BikeAnnotationCollection {

	private(set) var bikeAnnotations: [BikeAnnotation]
	
	init(POIs: [AMapPOI]) {
		bikeAnnotations = POIs.map {
			let latitude = CLLocationDegrees($0.location.latitude)
			let longitude = CLLocationDegrees($0.location.longitude)
			let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			let annotation = BikeAnnotation()
			annotation.coordinate = coordinate
			return annotation
		}
	}
}

extension BikeAnnotationCollection {

	func add(to mapView: MAMapView) {
		mapView.addAnnotations(bikeAnnotations)
	}

	func remove(from mapView: MAMapView) {
		let oldBikeAnnotations = (mapView.annotations as! [MAAnnotation]).filter { $0 is BikeAnnotation }
		mapView.removeAnnotations(oldBikeAnnotations)
	}
}
