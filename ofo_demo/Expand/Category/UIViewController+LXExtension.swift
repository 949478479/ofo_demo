//
//  UIViewController+LXExtension.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/16.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

extension Swifty where Base: UIViewController {
	func setNavigationBarTranslucent() {
		let navigationBar = base.lx_navigationBar()
		navigationBar?.shadowImage = UIImage()
		navigationBar?.setBackgroundImage(UIImage(), for: .default)
	}
}
