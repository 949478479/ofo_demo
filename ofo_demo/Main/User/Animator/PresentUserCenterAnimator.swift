//
//  PresentUserCenterAnimator.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/21.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class PresentUserCenterAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to) as! UINavigationController
        transitionContext.containerView.addSubview(toVC.view)

        let containerVC = toVC.childViewControllers[0] as! UserCenterContainerViewController
        let tableViewContainerView = containerVC.tableViewContainerView!
        let topBackgroundView = containerVC.topBackgroundView!
        containerVC.view.layoutIfNeeded()
        topBackgroundView.transform = CGAffineTransform(translationX: 0, y: -topBackgroundView.lx_height)
        tableViewContainerView.transform = CGAffineTransform(translationX: 0, y: tableViewContainerView.lx_height + containerVC.extraContainerViewHeight)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            topBackgroundView.transform = .identity
            tableViewContainerView.transform = .identity
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
