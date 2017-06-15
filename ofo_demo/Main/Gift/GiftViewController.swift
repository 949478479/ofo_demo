//
//  GiftViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class GiftViewController: WebViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://m.ofo.so/active.html")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
}
