//
//  AppDelegate.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/14.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let shared = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// 防止视频背景尚未来得及播放时出现黑色背景
        RunLoop.main.run(until: Date())
		configureAMap()
        configureAppearance()
        return true
    }
}

// MARK: - 设置外观
extension AppDelegate {
    func configureAppearance() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.backIndicatorImage = UIImage()
        navigationBar.backIndicatorTransitionMaskImage = UIImage()
    }
}

// MARK: 配置高德地图
extension AppDelegate {
	func configureAMap() {
		AMapServices.shared().enableHTTPS = true
		AMapServices.shared().apiKey = "e681fc722c8f87d788458e1bc43d06d3"
	}
}
