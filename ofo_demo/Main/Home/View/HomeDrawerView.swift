//
//  HomeDrawerView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeDrawerView: UIView {

	@IBInspectable var arcHight: CGFloat = 0
    @IBInspectable var heightOnClose: CGFloat = 0
    @IBOutlet private var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.constant = heightOnClose
        }
    }

    @IBOutlet var handleButton: UIButton!
    @IBOutlet var userCenterButton: UIButton!
    @IBOutlet var giftCenterButton: UIButton!

    private(set) var isOpen = false
}

// MARK: - 绘制
extension HomeDrawerView {

	override func draw(_ rect: CGRect) {
		let path = CGMutablePath()
		path.move(to: CGPoint(x: rect.minX, y: arcHight))
		path.addQuadCurve(to: CGPoint(x: rect.maxX, y: arcHight), control: CGPoint(x: rect.midX, y: -arcHight))

		layer.shadowPath = path
		layer.shadowOpacity = 0.1

		path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

		let context = UIGraphicsGetCurrentContext()
		context?.addPath(path)
		context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
		context?.fillPath()
	}
}

// MARK: - 开合控制
extension HomeDrawerView {

	@IBAction func open() {
        guard !isOpen else {
            return
        }
        switchDrawerState()
    }

    @IBAction func close() {
        guard isOpen else {
            return
        }
        switchDrawerState()
    }

    @IBAction private func switchDrawerState() {
        if isOpen {
            isOpen = false
            handleButton.isSelected = false
            handleButton.lx_normalImage = #imageLiteral(resourceName: "arrowup")
            topConstraint.constant = heightOnClose
        } else {
            isOpen = true
            handleButton.isSelected = true
            handleButton.lx_normalImage = #imageLiteral(resourceName: "arrowdown")
            topConstraint.constant = lx_height
        }

        UIView.animate(withDuration: 0.25) {
            self.superview!.layoutIfNeeded()
        }

        if isOpen {
            let y = bounds.maxY - userCenterButton.lx_minY
            let transform = CGAffineTransform(translationX: 0, y: y)
            userCenterButton.transform = transform
            giftCenterButton.transform = transform
            UIView.animate(withDuration: 0.25, delay: 0.15, options: [], animations: {
                self.userCenterButton.transform = .identity
                self.giftCenterButton.transform = .identity
            })
        }
    }
}
