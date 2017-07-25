//
//  ReportMenuView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/20.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

@objc enum ReportType: Int {

	case park
	case nobike
	case broken
	case locked

	var title: String {
		switch self {
		case .park: return "乱停车"
		case .nobike: return "没车用"
		case .broken: return "车损坏"
		case .locked: return "车上锁"
		}
	}
}

@objc protocol ReportMenuViewDelegate {
	func reportMenuView(_ reportMenuView: ReportMenuView, didTapReportButtonFor reportType: ReportType)
}

class ReportMenuView: UIView {

	@IBOutlet weak var delegate: ReportMenuViewDelegate?
	
	private let animationDuration = 0.35
	@IBOutlet private var
	reportButtonContainers: [UIStackView]!
}

// MARK: - 触摸响应
extension ReportMenuView {

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		dismiss()
	}
}

// MARK: - 显示关闭菜单
extension ReportMenuView {

	func show() {
		let window = UIWindow.lx.key
		frame = window.bounds
		window.addSubview(self)

		alpha = 0
		UIView.animate(withDuration: animationDuration, animations: {
			self.alpha = 1
		})

		let animation = CABasicAnimation(keyPath: "transform.scale")
		animation.fromValue = 0
		animation.duration = animationDuration
		animation.fillMode = kCAFillModeBackwards
		animation.timingFunction = .easeInEaseOut
		animation.beginTime = CACurrentMediaTime()
		reportButtonContainers.enumerated().forEach { idx, view in
			animation.beginTime += Double(idx) * 0.02
			view.layer.add(animation, forKey: nil)
		}
	}

	@IBAction private func dismiss(_ sender: UIButton) {
		dismiss()
	}
	
	func dismiss(animated: Bool = true) {
		if animated {
			UIView.animate(withDuration: animationDuration, animations: {
				self.alpha = 0
			}) { (_) in
				self.removeFromSuperview()
			}
		} else {
			removeFromSuperview()
		}
	}
}

// MARK: - 按钮点击
private extension ReportMenuView {

	@IBAction func reportButtonDidTap(_ sender: UIButton) {
		delegate?.reportMenuView(self, didTapReportButtonFor: ReportType(rawValue: sender.tag)!)
	}
}

