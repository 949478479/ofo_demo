//
//  BikeNoInvalidAlertView.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/8/3.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class BikeNoInvalidAlertView: LXAlertView {

	override func alertView() -> UIView {
		return UINib(nibName: "BikeNoInvalidAlertView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
	}
}
