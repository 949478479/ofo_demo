//
//  LoginVideoViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/14.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class LoginVideoViewController: UIViewController {

    var playerViewContrller: AVPlayerViewController!

    deinit {
        removePlayerObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        playerViewContrller.player?.play()
    }
}

// MARK: - 状态栏
extension LoginVideoViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - segue
extension LoginVideoViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerViewContrller = segue.destination as? AVPlayerViewController {
            configure(playerViewController: playerViewContrller)
        }
    }
}

// MARK: - 配置播放器
extension LoginVideoViewController {

    func configure(playerViewController: AVPlayerViewController) {
        playerViewContrller = playerViewController
        if let videoURL = Bundle.main.url(forResource: "loginVideoV2", withExtension: "mp4") {
            let player = AVPlayer(url: videoURL)
            playerViewContrller.player = player
            playerViewContrller.showsPlaybackControls = false
            addPlayerObserver(for: player)
        }
    }

    func loopPlayVideo() {
        playerViewContrller.player?.seek(to: kCMTimeZero)
        playerViewContrller.player?.play()
    }

    func playVideo() {
        playerViewContrller.player?.play()
    }

    func pauseVideo() {
        playerViewContrller.player?.pause()
    }

    func addPlayerObserver(for player: AVPlayer) {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(loopPlayVideo), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        center.addObserver(self, selector: #selector(pauseVideo), name: .UIApplicationWillResignActive, object: nil)
        center.addObserver(self, selector: #selector(playVideo), name: .UIApplicationDidBecomeActive, object: nil)
    }

    func removePlayerObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 按钮点击
extension LoginVideoViewController {
    @IBAction func actionButtonTapped() {
        switchRootViewController()
    }
}

// MARK: - 切换控制器
extension LoginVideoViewController {
    func switchRootViewController() {
        playerViewContrller.player?.pause()

        let window = AppDelegate.shared.window!
        let homeVC = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController()!

        window.rootViewController = homeVC
        window.insertSubview(view, belowSubview: homeVC.view)

        UIView.transition(from: view, to: homeVC.view, duration: 0.25, options: .transitionCrossDissolve)
    }
}
