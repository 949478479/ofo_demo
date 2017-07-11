//
//  HomeViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

	@IBOutlet private var anchorView: HomeAnchorView!
	private let mapView = MAMapView()
	private let searchAPI = AMapSearchAPI()!
	private var didUpdateUserLocation = false
	private var userLocationView: MAAnnotationView {
		return mapView.view(for: mapView.userLocation)!
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		configureMapView()
		configureSearchAPI()
        setNavigationBarTranslucent()
    }
}

// MARK: - seuge
extension HomeViewController {
	@IBAction private func unwind(for unwindSegue: UIStoryboardSegue) {}
}

// MARK: - 地图
private extension HomeViewController {

	func configureMapView() {
		let representation = MAUserLocationRepresentation()
		representation.showsAccuracyRing = false
		mapView.update(representation)

		mapView.zoomLevel = 19
		mapView.delegate = self
		mapView.distanceFilter = 10
		mapView.showsCompass = false
		mapView.headingFilter = .pi / 6
		mapView.isRotateEnabled = false
		mapView.userTrackingMode = .follow
		mapView.isRotateCameraEnabled = false
		mapView.allowsBackgroundLocationUpdates = true
		mapView.screenAnchor = CGPoint(x: 0.5, y: 0.375)
		mapView.pausesLocationUpdatesAutomatically = false
		mapView.showsUserLocation = true
		
		view.insertSubview(mapView, at: 0)
		mapView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}

	func configureUserLocationView() {
		let headingIndicatorLayer = CALayer()
		headingIndicatorLayer.contents = #imageLiteral(resourceName: "Homepage_userLocation").cgImage
		headingIndicatorLayer.frame = userLocationView.bounds.insetBy(dx: -8, dy: -8)
		userLocationView.layer.insertSublayer(headingIndicatorLayer, at: 0)
		(userLocationView.value(forKey: "_innerBaseLayer") as! CALayer).shadowOpacity = 0
	}

	func updateUserHeading() {
		let degree = mapView.userLocation.heading.trueHeading - Double(mapView.rotationDegree)
		userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(degree * .pi / 180))
	}

	func addAnnotations(for POIs: [AMapPOI]) {
		let oldAnnotations = (mapView.annotations as! [MAAnnotation]).filter { !($0 is MAUserLocation) }
		mapView.removeAnnotations(oldAnnotations as [Any])

		let newAnnotations = POIs.map { poi -> MAPointAnnotation in
			let annotation = MAPointAnnotation()
			annotation.coordinate = {
				let latitude = CLLocationDegrees(poi.location.latitude)
				let longitude = CLLocationDegrees(poi.location.longitude)
				return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			}()
			return annotation
		}
		mapView.addAnnotations(newAnnotations as [Any])
	}

	func bringUserLocationViewToFont() {
		let userLocationView = self.userLocationView
		userLocationView.superview?.bringSubview(toFront: userLocationView)
	}
}

// MARK: - 搜索
private extension HomeViewController {

	func configureSearchAPI() {
		searchAPI.delegate = self
	}

	func performAroundSearch() {
		let request = AMapPOIAroundSearchRequest()
		request.radius = 100
		request.types = "餐饮服务"
		let centerCoordinate = mapView.centerCoordinate
		request.location = AMapGeoPoint.location(withLatitude: CGFloat(centerCoordinate.latitude), longitude: CGFloat(centerCoordinate.longitude))
		searchAPI.aMapPOIAroundSearch(request)
	}
}

// MARK: - MAMapViewDelegate
extension HomeViewController: MAMapViewDelegate {

	func mapInitComplete(_ mapView: MAMapView!) {
		configureUserLocationView()
	}

	func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
		bringUserLocationViewToFont()
	}

	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		if updatingLocation {
			if !didUpdateUserLocation && userLocation.location.timestamp.timeIntervalSinceNow > -10 {
				didUpdateUserLocation = true
				performAroundSearch()
			}
		} else {
			updateUserHeading()
		}
	}

	func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
		if wasUserAction {
			performAroundSearch()
			anchorView.performAnimation()
		}
	}

	func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
		guard annotation is MAUserLocation == false else {
			return nil
		}
		let annotationView = NearbyBikeAnnotationView.annotationView(with: mapView, for: annotation)
		return annotationView
	}
}

// MARK: - AMapSearchDelegate
extension HomeViewController: AMapSearchDelegate {

	func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
		print(error)
	}

	func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
		guard response.count > 0 else {
			return
		}
		addAnnotations(for: response.pois)
	}
}
