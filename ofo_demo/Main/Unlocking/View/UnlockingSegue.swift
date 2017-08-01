//
//  UnlockingSegue.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/8/1.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class UnlockingSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {

	override func perform() {
		destination.transitioningDelegate = self
		super.perform()
	}

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PresentUnlockingUIAnimator()
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return DismissUnlockingUIAnimator()
	}
}
