//
//  NumberKeyboardView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/8/2.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

@objc protocol NumberKeyboardViewDelegate: class {
	func keyboardViewShouldEnableDoneButton(_ keyboardView: NumberKeyboardView) -> Bool
	func keyboardViewDidTapDoneButton(_ keyboardView: NumberKeyboardView)
}

class NumberKeyboardView: UIView {

	@IBOutlet weak var delegate: NumberKeyboardViewDelegate?

	@IBOutlet private var doneButton: UIButton!
	private weak var textInput: UITextInput?

	deinit {
		removeObserver()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		addObserver()
	}
}

// MARK: - UIInputViewAudioFeedback
extension NumberKeyboardView: UIInputViewAudioFeedback {
	public var enableInputClicksWhenVisible: Bool {
		return true
	}
}

// MARK: - 通知
private extension NumberKeyboardView {

	func addObserver() {
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(textFieldTextDidBeginEditing(_:)), name: .UITextFieldTextDidBeginEditing, object: nil)
		center.addObserver(self, selector: #selector(textFieldTextDidEndEditing(_:)), name: .UITextFieldTextDidEndEditing, object: nil)
		center.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: .UITextFieldTextDidChange, object: nil)
	}

	func removeObserver() {
		NotificationCenter.default.removeObserver(self)
	}

	@objc func textFieldTextDidBeginEditing(_ notification: Notification) {
		guard let input = notification.object as? UIResponder & UITextInput else {
			return
		}
		guard input.inputView == self else {
			return
		}
		textInput = input
	}

	@objc func textFieldTextDidEndEditing(_ notification: Notification) {
		textInput = nil
	}

	@objc func textFieldTextDidChange(_ notification: Notification) {
		if let isEnabled = delegate?.keyboardViewShouldEnableDoneButton(self) {
			doneButton.isEnabled = isEnabled
		}
	}
}

// MARK: - 辅助方法
private extension NumberKeyboardView {

	func playInputClick() {
		UIDevice.current.playInputClick()
	}

	func selectedRange() -> NSRange {
		guard let textInput = textInput, let selectedTextRange = textInput.selectedTextRange else { fatalError() }
		let start = textInput.offset(from: textInput.beginningOfDocument, to: selectedTextRange.start)
		let end = textInput.offset(from: textInput.beginningOfDocument, to: selectedTextRange.end)
		return NSRange(location: start, length: end - start)
	}
}

// MARK: - 点击处理
private extension NumberKeyboardView {

	@IBAction func numberButtonDidTap(_ sender: UIButton) {
		guard let textInput = textInput else { return }
		guard let selectedTextRange = textInput.selectedTextRange else { return }

		playInputClick()

		let text = String(sender.tag)

		if let textField = textInput as? UITextField {
			let range = selectedRange()
			if let should = textField.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: text) {
				if should {
					textField.replace(selectedTextRange, withText: text)
				}
			} else {
				textField.replace(selectedTextRange, withText: text)
			}
		}
	}

	@IBAction func deleteButtonDidTap(_ sender: UIButton) {
		guard let textInput = textInput else { return }

		playInputClick()

		if let textField = textInput as? UITextField {
			let range = selectedRange()
			if let should = textField.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: "") {
				if should {
					textInput.deleteBackward()
				}
			} else {
				textInput.deleteBackward()
			}
		}
	}

	@IBAction func doneButtonDidTap(_ sender: UIButton) {
		delegate?.keyboardViewDidTapDoneButton(self)
	}
}
