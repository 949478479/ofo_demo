//
//  UserCenterSegue.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/21.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class UserCenterSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {

    override func perform() {
        destination.transitioningDelegate = self
        super.perform()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentUserCenterAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissUserCenterAnimator()
    }
}
