//
//  MBProgressHUD+LXExtension.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/12.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import MBProgressHUD

extension Swifty where Base == MBProgressHUD.Type {
	
	@discardableResult
	func showActivityIndicator(with status: String) -> MBProgressHUD {
		let hud = base.showAdded(to: UIWindow.lx_key(), animated: true)
		hud.margin = 8
		hud.isSquare = true
		hud.label.text = status
		hud.label.font = UIFont.systemFont(ofSize: 12)
		hud.mode = .customView
		hud.customView = UIImageView(image: #imageLiteral(resourceName: "HUD_Group"))
		let animation = CABasicAnimation(keyPath: "transform.rotation")
		animation.duration = 1
		animation.byValue = CGFloat.pi * 2
		animation.repeatCount = .infinity
		hud.customView?.layer.add(animation, forKey: nil)
		return hud
	}
	
	@discardableResult
	func showRoutePlanIndicator() -> MBProgressHUD {
		return showActivityIndicator(with: "路径规划中...")
	}

	func hiden(animated: Bool) {
		base.hide(for: UIWindow.lx_key(), animated: animated)
	}
}