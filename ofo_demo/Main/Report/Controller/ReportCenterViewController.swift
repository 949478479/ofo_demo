//
//  ReportCenterViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/19.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

enum ReportType: Int {
	
	case park
	case nobike
	case broken
	case locked

	var title: String {
		switch self {
		case .park: return "乱停放"
		case .nobike: return "没车用"
		case .broken: return "车损坏"
		case .locked: return "车上锁"
		}
	}
}

protocol ReportCenterViewControllerDelegate: class {
	func reportCenterViewController(_ reportCenterViewController: ReportCenterViewController, didTapReportButtonFor reportType: ReportType)
}

class ReportCenterViewController: UIViewController {

	@IBOutlet var reportButtonContainers: [UIStackView]!
	weak var delegate: ReportCenterViewControllerDelegate?
}

// MARK: - 视图周期
extension ReportCenterViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		lx.setNavigationBarTranslucent()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if isBeingPresented {
			animateReportButtons()
		}
	}
}

// MARK: - 触摸响应
extension ReportCenterViewController {

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		dismiss(animated: true, completion: nil)
	}
}

// MARK: - 按钮动画
private extension ReportCenterViewController {

	func animateReportButtons() {
		let animation = CABasicAnimation(keyPath: "transform.scale")
		animation.duration = 0.35
		animation.fromValue = 0
		animation.fillMode = kCAFillModeBackwards
		animation.timingFunction = .easeInEaseOut
		animation.beginTime = CACurrentMediaTime()
		reportButtonContainers.enumerated().forEach { idx, view in
			animation.beginTime += Double(idx) * 0.02
			view.layer.add(animation, forKey: nil)
		}
	}
}

// MARK: - 按钮点击
private extension ReportCenterViewController {

	@IBAction func reportButtonDidTap(_ sender: UIButton) {
		delegate?.reportCenterViewController(self, didTapReportButtonFor: ReportType(rawValue: sender.tag)!)
	}
}

