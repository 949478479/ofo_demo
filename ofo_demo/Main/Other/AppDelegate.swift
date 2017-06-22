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
        RunLoop.main.run(until: Date()) // 防止视频背景尚未来得及播放时出现黑色背景
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

