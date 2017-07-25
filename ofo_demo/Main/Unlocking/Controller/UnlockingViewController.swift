//
//  UnlockingViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/21.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class UnlockingViewController: UIViewController {

	private var messages: [String]?
	private let scanRectTop: CGFloat = 144
	private let scanRectSize: CGSize = CGSize(width: 257, height: 257)

	@IBOutlet private var scanner: LXQRCodeScanner!
	@IBOutlet private var scanningLine: UIImageView!
}

// MARK: - 视图周期
extension UnlockingViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		configureScanner()
		startScanning()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if isBeingDismissed {
			scanner.stopRunning(completion: nil)
		}
	}
}

// MARK: - 扫描器控制
private extension UnlockingViewController {

	func configureScanner() {
		var rectOfInterest = CGRect()
		rectOfInterest.origin.x = (view.bounds.width - scanRectSize.width) / 2 / view.bounds.width
		rectOfInterest.origin.y = scanRectTop / view.bounds.height
		rectOfInterest.size.width = scanRectSize.width / view.bounds.width
		rectOfInterest.size.height = scanRectSize.height / view.bounds.height
		scanner.rectOfInterest = rectOfInterest

		scanner.completionBlock = { [unowned self] scanner, messages in
			self.messages = messages
			self.stopRunning()
		}
	}

	func animateScanningLine() {
		let animation = CABasicAnimation(keyPath: "position.y")
		animation.duration = 2
		animation.repeatCount = .infinity
		animation.timingFunction = .linear
		animation.fromValue = scanningLine.center.y - scanRectSize.height / 2
		animation.toValue = scanningLine.center.y + scanRectSize.height / 2
		scanningLine.layer.add(animation, forKey: "ScanningLineAnimation")
		scanningLine.isHidden = false
	}

	func hideScanningLine() {
		scanningLine.isHidden = true
		scanningLine.layer.removeAnimation(forKey: "ScanningLineAnimation")
	}

	func startScanning() {
		scanner.startRunning { [unowned self] success, error in
			if success {
				self.animateScanningLine()
			}
		}
	}

	func stopRunning() {
		hideScanningLine()
		scanner.stopRunning { [unowned self] in
			let alert = UIAlertController(title: "扫码成功", message: self.messages?.joined(separator: "\n"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "继续扫码", style: .default, handler: { _ in
				self.startScanning()
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
}

private extension UnlockingViewController {

	@IBAction func torchButtonDidTap(_ sender: UIButton) {
		sender.isSelected = !sender.isSelected
		scanner.isTorchActive = sender.isSelected
	}
}
