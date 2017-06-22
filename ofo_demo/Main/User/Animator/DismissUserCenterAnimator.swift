//
//  DismissUserCenterAnimator.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/21.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class DismissUserCenterAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from) as! UINavigationController
        let containerVC = fromVC.childViewControllers[0] as! UserCenterContainerViewController
        let tableViewContainerView = containerVC.tableViewContainerView!
        let topBackgroundView = containerVC.topBackgroundView!
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            topBackgroundView.transform = CGAffineTransform(translationX: 0, y: -topBackgroundView.lx_height)
            tableViewContainerView.transform = CGAffineTransform(translationX: 0, y: tableViewContainerView.lx_height + containerVC.extraContainerViewHeight)
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}
