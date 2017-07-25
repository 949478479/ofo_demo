//
//  HomeDrawerView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeDrawerView: UIView {

	var arcHight: CGFloat = 40
    var heightOnClose: CGFloat = 68
	@IBOutlet private var topConstraint: NSLayoutConstraint! {
		didSet {
			topConstraint.constant = heightOnClose
		}
	}

	var startButtonTopConstantOnOpen: CGFloat = 40
	var startButtonTopConstantOnClose: CGFloat = 60
	@IBOutlet private var startButtonTopConstraint: NSLayoutConstraint!

	@IBOutlet private var startButton: UIButton!
    @IBOutlet private var handleButton: UIButton!
    @IBOutlet private var userCenterButton: UIButton!
    @IBOutlet private var giftCenterButton: UIButton!

    private(set) var isOpen = false
}

// MARK: - 绘制
extension HomeDrawerView {

	override func draw(_ rect: CGRect) {
		let path = CGMutablePath()
		path.move(to: CGPoint(x: rect.minX, y: arcHight))
		path.addQuadCurve(to: CGPoint(x: rect.maxX, y: arcHight), control: CGPoint(x: rect.midX, y: -arcHight))

		layer.shadowPath = path
		layer.shadowRadius = 7
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
            handleButton.lx_normalImage = #imageLiteral(resourceName: "arrowup")
            topConstraint.constant = heightOnClose
			startButtonTopConstraint.constant = startButtonTopConstantOnClose
        } else {
            isOpen = true
            handleButton.lx_normalImage = #imageLiteral(resourceName: "arrowdown")
            topConstraint.constant = lx_height
			startButtonTopConstraint.constant = startButtonTopConstantOnOpen
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
