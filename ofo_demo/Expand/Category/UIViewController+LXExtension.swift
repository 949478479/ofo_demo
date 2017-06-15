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
        let background = UIView()
        view.addSubview(background)
        background.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.top.left.right.equalToSuperview()
        }

        let shadow = UIImageView(image: #imageLiteral(resourceName: "shadow"))
        view.addSubview(shadow)
        shadow.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(64)
        }
    }
}
