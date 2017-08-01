//
//  PresentUnlockingUIAnimator.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/8/1.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class PresentUnlockingUIAnimator: NSObject, UIViewControllerAnimatedTransitioning {

	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.35
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let toView = transitionContext.view(forKey: .to)!
		transitionContext.containerView.addSubview(toView)
		toView.alpha = 0
		toView.transform = CGAffineTransform(translationX: 0, y: toView.bounds.height)
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			toView.alpha = 1
			toView.transform = .identity
		}) { (_) in
			transitionContext.completeTransition(true)
		}
	}
}
