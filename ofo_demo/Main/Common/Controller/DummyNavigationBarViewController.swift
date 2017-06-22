//
//  DummyNavigationBarViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/22.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit
import SnapKit

class DummyNavigationBarViewController: UIViewController {

	private(set) lazy var dummyNavigationBar: DummyNavigationBar = {
		let dummyNavigationBar = DummyNavigationBar()
		self.view.addSubview(dummyNavigationBar)
		dummyNavigationBar.snp.makeConstraints {
			$0.top.left.right.equalToSuperview()
		}
		return dummyNavigationBar
	}()

	override var title: String? {
		didSet {
			navigationItem.title = nil
			dummyNavigationBar.titleLabel.text = title
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureDummyNavigationBarTitle()
	}
}

extension DummyNavigationBarViewController {

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		bringDummyNavigationBarToFont()
	}
}

extension DummyNavigationBarViewController {

	func bringDummyNavigationBarToFont() {
		view.bringSubview(toFront: dummyNavigationBar)
	}

	func configureDummyNavigationBarTitle() {
		dummyNavigationBar.titleLabel.text = title
	}
}
