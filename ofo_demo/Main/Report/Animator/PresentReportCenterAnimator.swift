//
//  PresentReportCenterAnimator.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/19.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class PresentReportCenterAnimator: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let toView = transitionContext.view(forKey: .to)!
		transitionContext.containerView.addSubview(toView)
		toView.alpha = 0
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			toView.alpha = 1
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}

