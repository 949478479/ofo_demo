//
//  HomeAnchorView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/7.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class HomeAnchorView: UIImageView {

	override var alignmentRectInsets: UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		image = #imageLiteral(resourceName: "homePage_wholeAnchor")
	}

	func performAnimation() {
		UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
			self.lx_centerY -= 20
		}, completion: { _ in
			UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
				self.lx_centerY += 20
			}, completion: nil)
		})
	}
}
