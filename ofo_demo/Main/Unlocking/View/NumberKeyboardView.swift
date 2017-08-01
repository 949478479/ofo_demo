//
//  NumberKeyboardView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/8/2.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

@objc protocol NumberKeyboardViewDelegate: class {
	func keyboardView(_ keyboardView: NumberKeyboardView, didTapButtonForNumber number: String)
	func keyboardViewShouldEnableDoneButton(_ keyboardView: NumberKeyboardView) -> Bool
	func keyboardViewDidTapDeleteButton(_ keyboardView: NumberKeyboardView)
	func keyboardViewDidTapDoneButton(_ keyboardView: NumberKeyboardView)
}

class NumberKeyboardView: UIView {

	@IBOutlet private var doneButton: UIButton!
	@IBOutlet weak var delegate: NumberKeyboardViewDelegate?
}

private extension NumberKeyboardView {

	@IBAction func numberButtonDidTap(_ sender: UIButton) {
		delegate?.keyboardView(self, didTapButtonForNumber: String(sender.tag))
		if let isEnabled = delegate?.keyboardViewShouldEnableDoneButton(self) {
			doneButton.isEnabled = isEnabled
		}
	}

	@IBAction func deleteButtonDidTap(_ sender: UIButton) {
		delegate?.keyboardViewDidTapDeleteButton(self)
		if let isEnabled = delegate?.keyboardViewShouldEnableDoneButton(self) {
			doneButton.isEnabled = isEnabled
		}
	}

	@IBAction func doneButtonDidTap(_ sender: UIButton) {
		delegate?.keyboardViewDidTapDoneButton(self)
	}
}
