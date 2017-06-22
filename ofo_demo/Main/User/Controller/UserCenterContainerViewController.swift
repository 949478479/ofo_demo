//
//  UserCenterContainerViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/21.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class UserCenterContainerViewController: UIViewController {

    @IBOutlet var topBackgroundView: UIView!
    @IBOutlet var tableViewContainerView: UIView!
    @IBInspectable var extraContainerViewHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
		setNavigationBarTranslucent()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		hideNavigationBar() // 隐藏系统导航栏，否则叉叉按钮无法点击了
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		showNavigationBar() // 显示系统导航栏，否则系统的返回按钮不能用了
	}
}

fileprivate extension UserCenterContainerViewController {

	func showNavigationBar() {
		navigationController?.isNavigationBarHidden = false
	}

	func hideNavigationBar() {
		navigationController?.isNavigationBarHidden = true
	}
}
