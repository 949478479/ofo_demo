//
//  HomeViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

	let mapView = MAMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
		configureMapView()
        setNavigationBarTranslucent()
    }
}

// MARK: - seuge
extension HomeViewController {
	@IBAction func unwind(for unwindSegue: UIStoryboardSegue) {}
}

// MARK: - 配置地图
extension HomeViewController {

	func configureMapView() {
		let representation = MAUserLocationRepresentation()
		representation.showsAccuracyRing = false
		mapView.update(representation)

		mapView.zoomLevel = 19
		mapView.delegate = self
		mapView.showsCompass = false
		mapView.isRotateEnabled = false
		mapView.isRotateCameraEnabled = false
		mapView.userTrackingMode = .follow
		mapView.allowsBackgroundLocationUpdates = true
		mapView.pausesLocationUpdatesAutomatically = false
		mapView.showsUserLocation = true
		
		view.addSubview(mapView)
		mapView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}

	func configureUserLocationView() {
		if let userLocationView = mapView.view(for: mapView.userLocation) {
			let headingIndicatorLayer = CALayer()
			headingIndicatorLayer.contents = #imageLiteral(resourceName: "Homepage_userLocation").cgImage
			headingIndicatorLayer.frame = userLocationView.bounds.insetBy(dx: -8, dy: -8)
			userLocationView.layer.insertSublayer(headingIndicatorLayer, at: 0)
			(userLocationView.value(forKey: "_innerBaseLayer") as! CALayer).shadowOpacity = 0
		}
	}

	func updateUserHeading() {
		if let userLocationView = mapView.view(for: mapView.userLocation) {
			let degree = mapView.userLocation.heading.trueHeading - Double(mapView.rotationDegree)
			userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(degree * .pi / 180))
		}
	}
}

// MARK: - MAMapViewDelegate
extension HomeViewController: MAMapViewDelegate {

	func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
		configureUserLocationView()
	}

	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		if !updatingLocation {
			updateUserHeading()
		}
	}
}
