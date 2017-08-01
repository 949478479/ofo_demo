//
//  DismissUnlockingUIAnimator.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/8/1.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class DismissUnlockingUIAnimator: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let fromView = transitionContext.view(forKey: .from)!
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			fromView.alpha = 0
			fromView.transform = CGAffineTransform(translationX: 0, y: fromView.bounds.height)
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}
