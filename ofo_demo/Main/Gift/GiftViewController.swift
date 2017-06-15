//
//  GiftViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/15.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class GiftViewController: UIViewController, DummyNavigationBar {

    let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure(webView: webView)
        configureDummyNavigationBar()
    }
}

// MARK: - 添加 WebView
extension GiftViewController {
    
    func configure(webView: WKWebView) {
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        let url = URL(string: "http://m.ofo.so/active.html")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
}
