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

	@IBOutlet private var torchButton1: UIButton!
	@IBOutlet private var torchButton2: UIButton!

	@IBOutlet private var scanner: LXQRCodeScanner!
	@IBOutlet private var scanningLine: UIImageView!
	@IBOutlet private var scanContainerView: UIView!

	private let inputTip1 = "输入车牌号，获取解锁码"
	private let inputTip2 = "车牌号一般为4~8位的数字"
	private let inputTip3 = "温馨提示：若输错车牌号，将无法打开车锁"

	@IBOutlet private var doneButton: UIButton!
	@IBOutlet private var keyboardView: UIView!
	@IBOutlet private var inputTipLabel: UILabel!
	@IBOutlet private var inputContainerView: UIView!
	@IBOutlet private var inputTextField: UITextField!
	@IBOutlet private var inputTextFieldContainerView: UIView!
	@IBOutlet private var keyboardSpacingView: LXKeyboardSpacingView!
	private lazy var drawerView: UIView = {
		return (presentingViewController?.childViewControllers.first as! HomeViewController).drawerView!
	}()

	deinit {
		scanner.isTorchActive = false
		scanner.stopRunning(completion: nil)
	}
}

// MARK: - 视图周期
extension UnlockingViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		configureTextField()
		configureScanner()
		startRunning()
	}
}

// MARK: - 扫描器
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
			self.stopRunningWhenScanSuccess()
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

	func startRunning() {
		scanner.startRunning { [unowned self] success, error in
			if success {
				self.animateScanningLine()
			}
		}
	}

	func stopRunning(completion: @escaping () -> Void) {
		hideScanningLine()
		scanner.stopRunning(completion: completion)
	}

	func stopRunningWhenScanSuccess() {
		hideScanningLine()
		scanner.stopRunning { [unowned self] in
			let alert = UIAlertController(title: "扫码成功", message: self.messages?.joined(separator: "\n"), preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: "继续扫码", style: .default, handler: { _ in
				self.startRunning()
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
}

private extension UnlockingViewController {

	func configureTextField() {
		inputTextField.placeholderFont = UIFont.systemFont(ofSize: 15)
	}
}

// MARK: - 按钮交互
private extension UnlockingViewController {

	@IBAction func inputButtonDidTap(_ sender: UIButton) {
		let drawerView = (presentingViewController?.childViewControllers.first as! HomeViewController).drawerView!
		drawerView.alpha = 0

		stopRunning(completion: {
			self.scanner.isTorchActive = self.torchButton1.isSelected
		})
		torchButton2.isSelected = torchButton1.isSelected
		torchButton2.lx_normalImage = torchButton2.isSelected ? #imageLiteral(resourceName: "btn_enableTorch") : #imageLiteral(resourceName: "btn_disableTorch")

		scanContainerView.isHidden = true
		inputContainerView.isHidden = false

		inputTextField.inputView = keyboardView
		inputTextField.becomeFirstResponder()
	}

	@IBAction func torchButtonDidTap(_ sender: UIButton) {
		if sender == torchButton1 {
			torchButton1.lx_normalImage = sender.isSelected ? #imageLiteral(resourceName: "btn_torch_disable") : #imageLiteral(resourceName: "btn_torch_enable")
		} else if sender == torchButton2 {
			torchButton2.lx_normalImage = sender.isSelected ? #imageLiteral(resourceName: "btn_disableTorch") : #imageLiteral(resourceName: "btn_enableTorch")
		}
		sender.isSelected = !sender.isSelected
		scanner.isTorchActive = sender.isSelected
	}

	@IBAction func voiceButtonDidTap(_ sender: UIButton) {
		sender.lx_normalImage = sender.isSelected ? #imageLiteral(resourceName: "voice_icon") : #imageLiteral(resourceName: "voice_close")
		sender.isSelected = !sender.isSelected
	}

	@IBAction func scanButtonDidTap(_ sender: UIButton) {
		startRunning()
		inputTextField.resignFirstResponder()
		drawerView.alpha = 1
		scanContainerView.isHidden = false
		inputContainerView.isHidden = true
		torchButton1.isSelected = scanner.isTorchActive
		torchButton1.lx_normalImage = torchButton1.isSelected ? #imageLiteral(resourceName: "btn_torch_enable") : #imageLiteral(resourceName: "btn_torch_disable")
	}

	@IBAction func dismissInputButtonDidTap(_ sender: UIButton) {
		sender.isHidden = true
		keyboardSpacingView.heightConstraint = nil

		let y = drawerView.frame.minY - inputTextFieldContainerView.frame.minY
		drawerView.transform = CGAffineTransform(translationX: 0, y: -y)

		if inputTextField.isFirstResponder {
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(with:)), name: .UIKeyboardWillHide, object: nil)
			inputTextField.resignFirstResponder()
		} else {
			UIView.animate(withDuration: 0.25, animations: {
				self.drawerView.alpha = 1
				self.drawerView.transform = .identity
				self.inputContainerView.alpha = 0
				self.inputContainerView.transform = CGAffineTransform(translationX: 0, y: y)
			}, completion: { (_) in
				self.dismiss(animated: false, completion: nil)
			})
		}
	}

	@objc func keyboardWillHide(with notification: Notification) {
		let drawerView = (presentingViewController?.childViewControllers.first as! HomeViewController).drawerView!
		let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
		UIView.animate(withDuration: duration, animations: {
			drawerView.alpha = 1
			drawerView.transform = .identity
			self.inputContainerView.alpha = 0
			let y = self.keyboardView.bounds.height + self.inputTextFieldContainerView.bounds.height - drawerView.bounds.height
			self.inputContainerView.transform = CGAffineTransform(translationX: 0, y: y)
		}, completion: { (_) in
			NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
			self.dismiss(animated: false, completion: nil)
		})
	}

	@IBAction func doneButtonDidTap(_ sender: UIButton) {
		inputTextField.resignFirstResponder()
		BikeNoInvalidAlertView().show()
	}

	@IBAction func inputFieldEditingChanged(_ sender: UITextField) {
		doneButton.isEnabled = sender.text!.count >= 4
		switch sender.text?.count {
		case 0?:
			inputTipLabel.text = inputTip1
		case (1..<4)?:
			inputTipLabel.text = inputTip2
		case (4...)?:
			inputTipLabel.text = inputTip3
		default:
			break
		}
	}
}

// MARK: - UITextFieldDelegate
extension UnlockingViewController: UITextFieldDelegate {

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard string.index(where: { Int(String($0)) == nil }) == nil else {
			return false
		}
		return textField.text!.count - range.length + string.count <= 11
	}
}

// MARK: - NumberKeyboardViewDelegate
extension UnlockingViewController: NumberKeyboardViewDelegate {

	func keyboardView(_ keyboardView: NumberKeyboardView, didTapButtonForNumber number: String) {
		if inputTextField.text!.count < 11 {
			inputTextField.insertText(number)
		}
	}

	func keyboardViewShouldEnableDoneButton(_ keyboardView: NumberKeyboardView) -> Bool {
		return inputTextField.text!.count >= 4
	}


	func keyboardViewDidTapDeleteButton(_ keyboardView: NumberKeyboardView) {
		inputTextField.deleteBackward()
	}

	func keyboardViewDidTapDoneButton(_ keyboardView: NumberKeyboardView) {
		inputTextField.resignFirstResponder()
		BikeNoInvalidAlertView().show()
	}
}
