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

	@IBOutlet private var locationButton: HomeLocationButton!

	private let mapView = MAMapView()
	private let mapSearchor = MapSearchor()

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
        lx.setNavigationBarTranslucent()
		mapSearchor.searchAPI.delegate = self
	}
}

// MARK: - seuge
extension HomeViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? ReportCenterViewController {
			destination.delegate = self
		}
	}

	@IBAction private func unwind(for unwindSegue: UIStoryboardSegue) {}
}

// MARK: - 悬浮按钮
private extension HomeViewController {

	@IBAction private func locationButtonDidTap(_ sender: HomeLocationButton) {
		guard !sender.isRefreshing else { return }
		if sender.buttonState == .refresh {
			sender.startRefreshAnimation()
			endRoutePlanModeIfNeeded()
			performPOIAroundSearch()
		} else if sender.buttonState == .location {
			sender.buttonState = .refresh
			previousAnchorCoordinate = mapView.userLocation.coordinate
			if isInRoutePlanMode {
				endRoutePlanModeIfNeeded()
			} else {
				mapView.centerCoordinate = previousAnchorCoordinate
			}
		}
	}
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

	func userLocationIsValid() -> Bool {
		guard let location = mapView.userLocation.location else {
			return false
		}
		let condition1 = location.horizontalAccuracy >= 0
		let condition2 = location.timestamp.timeIntervalSinceNow > -10
		return condition1 && condition2
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

	func removeBikeAnnotationsIfNeeded() {
		bikeAnnotationCollection?.remove(from: mapView)
	}

	func showBikeAnnotations(for POIs: [AMapPOI]) {
		bikeAnnotationCollection = BikeAnnotationCollection(POIs: POIs)
		bikeAnnotationCollection?.add(to: mapView)
	}
}

// MARK: - 搜索
private extension HomeViewController {

	func satisfyAnchorMovementThreshold() -> Bool {
		let p1 = MAMapPointForCoordinate(previousSearchCoordinate)
		let p2 = MAMapPointForCoordinate(previousAnchorCoordinate)
		let distance = MAMetersBetweenMapPoints(p1, p2)
		return distance > 10
	}

	func performPOIAroundSearch() {
		previousSearchCoordinate = previousAnchorCoordinate
		mapSearchor.performPOIAroundSearch(for: previousSearchCoordinate)
	}

	func performWalkingRouteSearch(for destination: CLLocationCoordinate2D) {
		routePlanIndicator = MBProgressHUD.lx.showRoutePlanIndicator()
		mapSearchor.performWalkingRouteSearch(for: previousAnchorCoordinate, destination: destination)
	}
}

// MARK: - 路径规划
private extension HomeViewController {

	func startRoutePlanMode(for route: AMapRoute) {
		isInRoutePlanMode = true
		anchorAnnotation?.isLockedToScreen = false
		removeRoute()
		showRoute(route)
		showBikeAnnotationCallout(for: route)
	}

	func endRoutePlanModeIfNeeded() {
		guard isInRoutePlanMode else {
			return
		}
		isInRoutePlanMode = false
		if let bikeAnnotation = mapView.selectedAnnotations?.first as? BikeAnnotation {
			mapView.deselectAnnotation(bikeAnnotation, animated: false)
		}
		removeRoute()
		anchorAnnotation?.isLockedToScreen = true
		mapView.centerCoordinate = previousAnchorCoordinate // 这里不能用动画，否则会导致 screenAnchor 属性无效
		mapView.setZoomLevel(18, animated: true)
	}

	func removeRoute() {
		navigationRoute?.remove(from: mapView)
		navigationRoute = nil
	}

	func showRoute(_ route: AMapRoute) {
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

// MARK: - MAMapViewDelegate
extension HomeViewController: MAMapViewDelegate {

	// MARK: 定位
	func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
		printLog("\(error)")
	}

	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		if updatingLocation {
			if !didUpdateUserLocation && userLocationIsValid() {
				didUpdateUserLocation = true
				initAnchorAnnotationIfNeeded()
				performPOIAroundSearch()
			}
		} else {
			updateUserHeading()
		}
	}

	// MARK: 点击
	func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
		endRoutePlanModeIfNeeded()
	}

	// MARK: 拖拽
	func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
		guard wasUserAction else { return }

		if mapView.centerCoordinate != mapView.userLocation.coordinate {
			locationButton.buttonState = .location
		}

		if !isInRoutePlanMode {
			previousAnchorCoordinate = mapView.centerCoordinate
			if satisfyAnchorMovementThreshold() {
				performPOIAroundSearch()
				anchorAnnotationView?.performBounceAnimation()
			}
		}
	}

	// MARK: 点标记
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

	// MARK: 折线
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
		if request is AMapPOISearchBaseRequest {
			locationButton.stopRefreshAnimation()
			removeBikeAnnotationsIfNeeded()
		} else if request is AMapRouteSearchBaseRequest {
			routePlanIndicator?.lx.hide()
			endRoutePlanModeIfNeeded()
		}
		printLog("\(error)")
	}

	// MARK: 兴趣点
	func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
		locationButton.stopRefreshAnimation()
		removeBikeAnnotationsIfNeeded()
		if response.count > 0 {
			showBikeAnnotations(for: response.pois)
		}
	}

	// MARK: 路径规划
	func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
		routePlanIndicator?.lx.hide()
		if response.count > 0 {
			startRoutePlanMode(for: response.route)
		} else {
			endRoutePlanModeIfNeeded()
		}
	}
}

// MARK: - ReportCenterViewControllerDelegate
extension HomeViewController: ReportCenterViewControllerDelegate {

	func reportCenterViewController(_ reportCenterViewController: ReportCenterViewController, didTapReportButtonFor reportType: ReportType) {
		reportCenterViewController.dismiss(animated: false, completion: nil)
		let webViewController = WebViewController()
		webViewController.title = reportType.title
		show(webViewController, sender: self)
	}
}
