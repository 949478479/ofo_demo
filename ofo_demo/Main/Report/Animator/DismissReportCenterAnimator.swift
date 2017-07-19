//
//  DismissReportCenterAnimator.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/19.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class DismissReportCenterAnimator: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			transitionContext.view(forKey: .from)?.alpha = 0
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}
