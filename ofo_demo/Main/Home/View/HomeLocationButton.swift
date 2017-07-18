//
//  HomeLocationButton.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/18.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeLocationButton: UIButton {

	enum State {
		case refresh
		case location
	}

	var buttonState: State = .refresh {
		didSet {
			switch buttonState {
			case .refresh:
				lx_normalImage = #imageLiteral(resourceName: "leftBottomRefreshImage")
			case .location:
				lx_normalImage = #imageLiteral(resourceName: "leftBottomImage")
			}
		}
	}

	private(set) var isRefreshing = false
}

extension HomeLocationButton {

	func startRefreshAnimation() {
		isRefreshing = true
		let animation = CABasicAnimation(keyPath: "transform.rotation")
		animation.duration = 0.5
		animation.byValue = CGFloat.pi * 2
		animation.repeatCount = .infinity
		imageView?.layer.add(animation, forKey: "RefreshAnimation")
	}

	func stopRefreshAnimation() {
		isRefreshing = false
		imageView?.layer.removeAnimation(forKey: "RefreshAnimation")
	}
}
