//
//  NSObjectProtocol+LXExtension.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/7/12.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import Foundation

struct Swifty<Base> {
	let base: Base
	init(_ base: Base) {
		self.base = base
	}
}

extension NSObjectProtocol {
	var lx: Swifty<Self> {
		return Swifty(self)
	}
	static var lx: Swifty<Self.Type> {
		return Swifty(self)
	}
}
