//
//  UIView+LXExtension.swift
//
//  Created by 从今以后 on 15/11/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

import UIKit

extension Swifty where Base: UIView {

	static func instantiateFromNib(withOwner ownerOrNil: AnyObject? = nil, options optionsOrNil: [AnyHashable: Any]? = nil) -> Base {
		let views = UINib(nibName: String(describing: Base.self), bundle: nil).instantiate(withOwner: ownerOrNil, options: optionsOrNil)
		guard let view = views.first(where: { type(of: $0) == Base.self }) as? Base else {
			fatalError("\(String(describing: Base.self)).xib 文件中未找到对应实例.")
		}
		return view
	}
}
