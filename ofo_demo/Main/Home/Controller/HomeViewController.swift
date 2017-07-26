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

	@IBOutlet private var reportMenu: ReportMenuView!
	@IBOutlet private var locationButton: HomeLocationButton!

	private let mapView = MAMapView()
	private let mapSearchor = MapSearchor()

	private var didUpdateUserLocation = false
	private var userLocationView: MAAnnotationView?

	private var anchorAnnotation: AnchorAnnotation?
	private var anchorAnnotationView: AnchorAnnotationView?

	private var searchStartCoordinate = CLLocationCoordinate2D()
	private var bikeAnnotationCollection: BikeAnnotationCollection?

	private var isInRoutePlanMode = false
	private var navigationRoute: NavigationRoute?
	private var routePlanIndicator: MBProgressHUD?
	private var routeStartCoordinate = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
		configureMapView()
        lx.setNavigationBarTranslucent()
		mapSearchor.searchAPI.delegate = self
	}
}

// MARK: - seuge
extension HomeViewController {
	@IBAction private func unwind(for unwindSegue: UIStoryboardSegue) {}
}

// MARK: - 悬浮按钮
private extension HomeViewController {

	@IBAction private func reportButtonDidTap(_ sender: UIButton) {
		reportMenu.show()
	}

	@IBAction private func locationButtonDidTap(_ sender: HomeLocationButton) {
		guard !sender.isRefreshing else { return }
		if sender.buttonState == .refresh {
			sender.startRefreshAnimation()
			if isInRoutePlanMode {
				endRoutePlanMode(forMapCenter: mapView.userLocation.coordinate)
			}
			performPOIAroundSearch()
		} else if sender.buttonState == .location {
			sender.buttonState = .refresh
			if isInRoutePlanMode {
				endRoutePlanMode(forMapCenter: mapView.userLocation.coordinate)
			} else {
				mapView.centerCoordinate = mapView.userLocation.coordinate
			}
		}
	}

	func switchLocationButtonStateIfNeeded() {
		let p1 = MAMapPointForCoordinate(mapView.centerCoordinate)
		let p2 = MAMapPointForCoordinate(mapView.userLocation.coordinate)
		let distance = MAMetersBetweenMapPoints(p1, p2)
		if distance > 1 {
			locationButton.buttonState = .location
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
		mapView.touchPOIEnabled = false
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
		let condition2 = location.timestamp.timeIntervalSinceNow > -1
		return condition1 && condition2
	}

	func initUserLocationViewIfNeeded() {
		guard userLocationView == nil else {
			return
		}
		guard let userLocationView = mapView.view(for: mapView.userLocation) else {
			return
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

	func addAnchorAnnotation() {
		let lockedScreenPoint = CGPoint(x: view.bounds.midX, y: view.bounds.height * mapView.screenAnchor.y)
		let annotation = AnchorAnnotation(coordinate: mapView.centerCoordinate, lockedScreenPoint: lockedScreenPoint)
		anchorAnnotation = annotation
		anchorAnnotation?.add(to: mapView)
	}

	func initAnchorViewIfNeeded() {
		guard let anchorAnnotation = anchorAnnotation else {
			return
		}
		if anchorAnnotationView == nil {
			anchorAnnotationView = mapView.view(for: anchorAnnotation) as? AnchorAnnotationView
		}
	}

	func bringAnchorViewToFont() {
		if let anchorAnnotationView = anchorAnnotationView {
			anchorAnnotationView.superview?.bringSubview(toFront: anchorAnnotationView)
		}
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

	func shouldPerformPOIAroundSearch() -> Bool {
		let p1 = MAMapPointForCoordinate(searchStartCoordinate)
		let p2 = MAMapPointForCoordinate(mapView.centerCoordinate)
		let distance = MAMetersBetweenMapPoints(p1, p2)
		return distance > 10
	}

	func performPOIAroundSearch() {
		searchStartCoordinate = mapView.centerCoordinate
		mapSearchor.performPOIAroundSearch(for: searchStartCoordinate)
	}

	func performWalkingRouteSearch(for destination: CLLocationCoordinate2D) {
		routePlanIndicator = MBProgressHUD.lx.showRoutePlanIndicator()
		if !isInRoutePlanMode {
			routeStartCoordinate = mapView.centerCoordinate
		}
		mapSearchor.performWalkingRouteSearch(for: routeStartCoordinate, destination: destination)
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

	func endRoutePlanMode(forMapCenter centerCoordinate: CLLocationCoordinate2D) {
		isInRoutePlanMode = false
		if let bikeAnnotation = mapView.selectedAnnotations?.first as? BikeAnnotation {
			mapView.deselectAnnotation(bikeAnnotation, animated: false)
		}
		removeRoute()
		anchorAnnotation?.isLockedToScreen = true
		mapView.centerCoordinate = centerCoordinate // 使用动画会导致 screenAnchor 属性无效
		mapView.setZoomLevel(18, animated: true)
	}

	func removeRoute() {
		navigationRoute?.remove(from: mapView)
		navigationRoute = nil
	}

	func showRoute(_ route: AMapRoute) {
		let endCoordinate = (mapView.selectedAnnotations[0] as! BikeAnnotation).coordinate
		navigationRoute = NavigationRoute(path: route.paths[0], startCoordinate: routeStartCoordinate, endCoordinate: endCoordinate)
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
		if let error = error as? CLError {
			switch error.code {
			case .denied:
				if CLLocationManager.authorizationStatus() == .denied {
					showLocationServiceWasDeniedAlert()
				}
			case .network:
				showNetworkErrorOccurredAlert()
			case .locationUnknown:
				showLocationUnknownAlert()
			default:
				break
			}
		}
		printLog("\(error as! CLError)")
	}

	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		if updatingLocation {
			if !didUpdateUserLocation && userLocationIsValid() {
				didUpdateUserLocation = true
				addAnchorAnnotation()
				performPOIAroundSearch()
			}
			switchLocationButtonStateIfNeeded()
		} else {
			updateUserHeading()
		}
	}

	// MARK: 点击
	func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
		if isInRoutePlanMode {
			endRoutePlanMode(forMapCenter: routeStartCoordinate)
		}
	}

	// MARK: 移动
	func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
		switchLocationButtonStateIfNeeded()
		if wasUserAction {
			if !isInRoutePlanMode && shouldPerformPOIAroundSearch() {
				performPOIAroundSearch()
				anchorAnnotationView?.performBounceAnimation()
			}
		}
	}

	// MARK: 点标记
	func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
		initUserLocationViewIfNeeded()
		initAnchorViewIfNeeded()
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
			if isInRoutePlanMode {
				endRoutePlanMode(forMapCenter: routeStartCoordinate)
			}
		}

		printLog("\(error)")

		switch (error as NSError).code {
		case 1806:
			MBProgressHUD.lx.showStatus("加载附近车辆位置失败，网络异常")
		default:
			break
		}
	}

	// MARK: 兴趣点
	func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
		locationButton.stopRefreshAnimation()
		removeBikeAnnotationsIfNeeded()
		if response.count > 0 {
			showBikeAnnotations(for: response.pois)
			anchorAnnotationView?.showCallout = false
		} else {
			anchorAnnotationView?.showCallout = true
		}
	}

	// MARK: 路径规划
	func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
		routePlanIndicator?.lx.hide()
		if response.count > 0 {
			startRoutePlanMode(for: response.route)
		} else if isInRoutePlanMode {
			endRoutePlanMode(forMapCenter: routeStartCoordinate)
		}
	}
}

// MARK: - ReportCenterViewControllerDelegate
extension HomeViewController: ReportMenuViewDelegate {

	func reportMenuView(_ reportMenuView: ReportMenuView, didTapReportButtonFor reportType: ReportType) {
		reportMenuView.dismiss(animated: false)
		let webViewController = WebViewController()
		webViewController.title = reportType.title
		show(webViewController, sender: self)
	}
}

// MARK: - 弹窗
extension HomeViewController {

	func showAlert(withTitle title: String? = nil, message: String? = nil, url: String = UIApplicationOpenSettingsURLString) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { (_) in
			UIApplication.shared.openURL(URL(string: url)!)
		}))
		present(alert, animated: true, completion: nil)
	}

	func showLocationServiceWasDeniedAlert() {
		showAlert(withTitle: "请允许“ofo共享单车”使用您的位置")
	}

	func showNetworkErrorOccurredAlert() {
		showAlert(withTitle: "网络连接出了问题", message: "请检查您的网络连接\n或者进入“设置”中允许“ofo共享单车”访问网络数据")
	}

	func showLocationUnknownAlert() {
		showAlert(message: "打开无线局域网将提高定位准确性", url: "App-Prefs:root=WIFI")
	}
}
