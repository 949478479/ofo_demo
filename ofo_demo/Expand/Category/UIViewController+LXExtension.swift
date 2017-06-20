//
//  UIViewController+LXExtension.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/16.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit
import SnapKit

protocol DummyNavigationBar {
    func configureDummyNavigationBar()
}

extension DummyNavigationBar where Self: UIViewController {

    func configureDummyNavigationBar() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.top.left.right.equalToSuperview()
        }

        let shadowView = UIImageView(image: #imageLiteral(resourceName: "shadow"))
        view.addSubview(shadowView)
        shadowView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(64)
        }
    }
}

protocol TranslucentNavigationBar {
    func setNavigationBarTranslucent()
}

extension TranslucentNavigationBar where Self: UIViewController {
    func setNavigationBarTranslucent() {
        let navigationBar = lx_navigationBar()
        navigationBar?.shadowImage = UIImage()
        navigationBar?.setBackgroundImage(UIImage(), for: .default)
    }
}
