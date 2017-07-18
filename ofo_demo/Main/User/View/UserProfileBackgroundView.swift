//
//  UserProfileBackgroundView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/18.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class UserProfileBackgroundView: UIView {

	@IBInspectable var arcHight: CGFloat = 0
	
	override func draw(_ rect: CGRect) {
		let path = CGMutablePath()
		path.move(to: CGPoint(x: rect.minX, y: arcHight))
		path.addQuadCurve(to: CGPoint(x: rect.maxX, y: arcHight), control: CGPoint(x: rect.midX, y: -arcHight))
		path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

		let context = UIGraphicsGetCurrentContext()
		context?.addPath(path)
		context?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
		context?.fillPath()
	}
}
