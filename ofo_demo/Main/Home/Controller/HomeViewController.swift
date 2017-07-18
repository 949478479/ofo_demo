//
//  HomeViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit
import MBProgressHUD

class HomeViewController: UIViewController {

	private let mapView = MAMapView()
	private let searchAPI = AMapSearchAPI()!

	private var didUpdateUserLocation = false
	private var userLocationView: MAAnnotationView?

	private var anchorAnnotation: AnchorAnnotation?
	private var anchorAnnotationView: AnchorAnnotationView?
	private var anchorMovementThreshold: CLLocationDistance = 0
	private var previousSearchCoordinate = CLLocationCoordinate2D()
	private var previousAnchorCoordinate = CLLocationCoordinate2D()

	private var bikeAnnotationCollection: BikeAnnotationCollection?

	private var isInRoutePlanMode = false
	private var navigationRoute: NavigationRoute?
	private var routePlanIndicator: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
		configureMapView()
		configureSearchAPI()
        lx.setNavigationBarTranslucent()
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

		mapView.zoomLevel = 18
		mapView.mapType = .bus
		mapView.delegate = self
		mapView.showsCompass = false
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
}

// MARK: - 用户位置
private extension HomeViewController {

	func userLocationIsStale() -> Bool {
		return mapView.userLocation.location.timestamp.timeIntervalSinceNow < -10
	}

	func configureUserLocationViewIfNeeded() {
		guard userLocationView == nil else {
			return
		}
		guard let userLocationView = mapView.view(for: mapView.userLocation) else {
			fatalError()
		}
		let headingIndicatorLayer = CALayer()
		headingIndicatorLayer.contents = #imageLiteral(resourceName: "Homepage_userLocation").cgImage
		headingIndicatorLayer.frame = userLocationView.bounds.insetBy(dx: -8, dy: -8)
		userLocationView.layer.insertSublayer(headingIndicatorLayer, at: 0)
		(userLocationView.value(forKey: "_innerBaseLayer") as! CALayer).shadowOpacity = 0
		self.userLocationView = userLocationView
	}

	func bringUserLocationViewToFont() {
		if let userLocationView = userLocationView {
			userLocationView.superview?.bringSubview(toFront: userLocationView)
		}
	}

	func updateUserHeading() {
		if let userLocationView = userLocationView {
			let degree = mapView.userLocation.heading.trueHeading - Double(mapView.rotationDegree)
			userLocationView.transform = CGAffineTransform(rotationAngle: CGFloat(degree * .pi / 180))
		}
	}
}

// MARK: - 定位锚点
private extension HomeViewController {

	func initAnchorAnnotationIfNeeded() {
		guard self.anchorAnnotation == nil else {
			return
		}
		let centerCoordinate = mapView.centerCoordinate
		previousAnchorCoordinate = centerCoordinate
		let lockedScreenPoint = CGPoint(x: view.bounds.midX, y: view.bounds.height * mapView.screenAnchor.y)
		let anchorAnnotation = AnchorAnnotation(coordinate: centerCoordinate, lockedScreenPoint: lockedScreenPoint)
		self.anchorAnnotation = anchorAnnotation
		anchorAnnotation.add(to: mapView)
	}

	func bringAnchorViewToFont() {
		guard let anchorAnnotation = anchorAnnotation else {
			return
		}
		if anchorAnnotationView == nil {
			anchorAnnotationView = mapView.view(for: anchorAnnotation) as? AnchorAnnotationView
		}
		anchorAnnotationView!.superview?.bringSubview(toFront: anchorAnnotationView!)
	}
}

// MARK: - 点标记
private extension HomeViewController {

	func showBikeAnnotations(for POIs: [AMapPOI]) {
		bikeAnnotationCollection?.remove(from: mapView)
		bikeAnnotationCollection = BikeAnnotationCollection(POIs: POIs)
		bikeAnnotationCollection?.add(to: mapView)
	}
}

// MARK: - 路径规划
private extension HomeViewController {

	func startRoutePlanMode(for route: AMapRoute) {
		isInRoutePlanMode = true
		anchorAnnotation?.isLockedToScreen = false
		show(route)
		showBikeAnnotationCallout(for: route)
	}

	func endRoutePlanMode() {
		guard isInRoutePlanMode else {
			return
		}
		isInRoutePlanMode = false
		navigationRoute?.remove(from: mapView)
		navigationRoute = nil
		anchorAnnotation?.isLockedToScreen = true
		mapView.centerCoordinate = previousAnchorCoordinate // 这里不能用动画，否则会导致 screenAnchor 属性无效
		mapView.setZoomLevel(18, animated: true)
	}

	func show(_ route: AMapRoute) {
		navigationRoute?.remove(from: mapView)
		let startCoordinate = previousAnchorCoordinate
		let endCoordinate = (mapView.selectedAnnotations[0] as! BikeAnnotation).coordinate
		navigationRoute = NavigationRoute(path: route.paths[0], startCoordinate: startCoordinate, endCoordinate: endCoordinate)
		navigationRoute?.add(to: mapView)
		let edgePadding = UIEdgeInsets(top: 100, left: 20, bottom: 100, right: 20)
		mapView.showOverlays([navigationRoute!.routePolyline], edgePadding: edgePadding, animated: true)
	}

	func showBikeAnnotationCallout(for route: AMapRoute) {
		let annotation = mapView.selectedAnnotations[0] as! BikeAnnotation
		let selectedBikeAnnotationView = mapView.view(for: annotation) as! BikeAnnotationView
		selectedBikeAnnotationView.configure(with: route.paths[0])
	}
}

// MARK: - 搜索
private extension HomeViewController {

	func configureSearchAPI() {
		searchAPI.delegate = self
	}

	func satisfyAnchorMovementThreshold() -> Bool {
		let p1 = MAMapPointForCoordinate(previousSearchCoordinate)
		let p2 = MAMapPointForCoordinate(previousAnchorCoordinate)
		let distance = MAMetersBetweenMapPoints(p1, p2)
		return distance > 10
	}

	func performPOIAroundSearch() {
		let request = AMapPOIAroundSearchRequest()
		request.radius = 200
		request.types = "餐饮服务"
		let centerCoordinate = previousAnchorCoordinate
		request.location = AMapGeoPoint.lx.location(with: centerCoordinate)
		searchAPI.aMapPOIAroundSearch(request)
		previousSearchCoordinate = centerCoordinate
	}

	func performWalkingRouteSearch(for destination: CLLocationCoordinate2D) {
		let origin = AMapGeoPoint.lx.location(with: previousAnchorCoordinate)
		let destination = AMapGeoPoint.lx.location(with: destination)

		let request = AMapWalkingRouteSearchRequest()
		request.origin = origin
		request.destination = destination

		routePlanIndicator = MBProgressHUD.lx.showRoutePlanIndicator()
		searchAPI.aMapWalkingRouteSearch(request)
	}
}

// MARK: - MAMapViewDelegate
extension HomeViewController: MAMapViewDelegate {

	// MARK: - 定位
	func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
		printLog("\(error)")
	}

	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		if updatingLocation {
			if !didUpdateUserLocation && !userLocationIsStale() {
				didUpdateUserLocation = true
				initAnchorAnnotationIfNeeded()
				performPOIAroundSearch()
			}
		} else {
			updateUserHeading()
		}
	}

	// MARK: - 点击
	func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
		endRoutePlanMode()
	}

	// MARK: - 拖拽
	func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
		guard wasUserAction else { return }
		if !isInRoutePlanMode {
			previousAnchorCoordinate = mapView.centerCoordinate
			if satisfyAnchorMovementThreshold() {
				performPOIAroundSearch()
				anchorAnnotationView?.performBounceAnimation()
			}
		}
	}

	// MARK: - 点标记
	func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
		configureUserLocationViewIfNeeded()
		bringUserLocationViewToFont()
		bringAnchorViewToFont()
	}

	func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
		if view.annotation is BikeAnnotation {
			performWalkingRouteSearch(for: view.annotation.coordinate)
		}
	}

	func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
		guard !(annotation is MAUserLocation) else {
			return nil
		}
		var annotationView: MAAnnotationView?
		if let annotation = annotation as? AnchorAnnotation {
			annotationView = AnchorAnnotationView.annotationView(with: mapView, for: annotation)
		} else if let annotation = annotation as? BikeAnnotation {
			annotationView = BikeAnnotationView.annotationView(with: mapView, for: annotation)
		}
		return annotationView
	}

	// MARK: - 折线
	func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
		guard let polyline = overlay as? RoutePolyline else {
			return nil
		}
		return navigationRoute?.renderer(for: polyline)
	}
}

// MARK: - AMapSearchDelegate
extension HomeViewController: AMapSearchDelegate {

	func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
		routePlanIndicator?.hide(animated: true)
		printLog("\(error)")
	}

	// MARK: - 兴趣点
	func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
		if response.count > 0 {
			showBikeAnnotations(for: response.pois)
		}
	}

	// MARK: - 路径规划
	func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
		routePlanIndicator?.hide(animated: true)
		if response.count > 0 {
			startRoutePlanMode(for: response.route)
		}
	}
}
