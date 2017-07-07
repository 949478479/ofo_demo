//
//  HomeDrawerView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeDrawerView: UIView {

    @IBInspectable @objc private var topOnClose: CGFloat = 0
    @IBOutlet private var topConstraint: NSLayoutConstraint! {
        didSet {
            topConstraint.constant = topOnClose
        }
    }

    @IBOutlet var userCenterButton: UIButton!
    @IBOutlet var giftCenterButton: UIButton!
    @IBOutlet private var handleButton: UIButton! {
        didSet {
            handleButton.addTarget(self, action: #selector(switchDrawerState), for: .touchUpInside)
        }
    }

    private(set) var isOpen = false

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

    @objc private func switchDrawerState() {
        if isOpen {
            isOpen = false
            handleButton.isSelected = false
            handleButton.lx_normalImage = #imageLiteral(resourceName: "arrowup")
            topConstraint.constant = topOnClose
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
