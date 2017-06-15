//
//  WebViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/16.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, DummyNavigationBar {

    fileprivate struct KVOContext {
        static var title = 0
        static var estimatedProgress = 0
    }

    let webView = WKWebView()
    fileprivate let progressView = UIProgressView()

    deinit {
        removeAllObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure(webView: webView)
        configure(progressView: progressView)
        configureDummyNavigationBar()
    }
}

// MARK: - 配置视图
private extension WebViewController {

    func configure(webView: WKWebView) {
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), context: &KVOContext.title)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: &KVOContext.estimatedProgress)
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(progressView: UIProgressView) {
        progressView.progressTintColor = UIColor(hex: 0xFAE24C)
        view.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(topLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - KVO
extension WebViewController {

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &KVOContext.title {
            title = webView.title
        }
        else if context == &KVOContext.estimatedProgress {
            progressView.progress = Float(webView.estimatedProgress)
        }
        else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    fileprivate func removeAllObservers() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
         progressView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
}
