//
//  ReportCenterSegue.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/19.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class ReportCenterSegue: UIStoryboardSegue {

	override func perform() {
		destination.transitioningDelegate = self
		super.perform()
	}
}

extension ReportCenterSegue: UIViewControllerTransitioningDelegate {

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return PresentReportCenterAnimator()
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return DismissReportCenterAnimator()
	}
}
