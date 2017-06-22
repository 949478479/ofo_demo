//
//  DummyNavigationBar.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/22.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class DummyNavigationBar: UIView {

	let titleLabel: UILabel
	let backButton: UIButton
	let backgroundView: UIView
	let shadowView: UIImageView

	init() {
		titleLabel = UILabel()
		backButton = UIButton()
		backButton.lx_normalImage = #imageLiteral(resourceName: "backIndicator")
		backgroundView = UIView()
		backgroundView.backgroundColor = .white
		shadowView = UIImageView(image: #imageLiteral(resourceName: "shadow"))
		super.init(frame: .zero)

		addSubview(backgroundView)
		backgroundView.snp.makeConstraints {
			$0.height.equalTo(64)
			$0.top.left.right.equalToSuperview()
		}

		addSubview(shadowView)
		shadowView.snp.makeConstraints {
			$0.left.right.equalToSuperview()
			$0.top.equalToSuperview().offset(64)
		}

		addSubview(backButton)
		backButton.snp.makeConstraints {
			$0.top.equalToSuperview().offset(34)
			$0.left.equalToSuperview().offset(8)
		}

		addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.centerY.equalToSuperview().offset(10)
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override var intrinsicContentSize: CGSize {
		return CGSize(width: UIViewNoIntrinsicMetric, height: 64)
	}
}
