//
//  UserCenterViewController.swift
//  ofo_demo
//
//  Created by 从今以后 on 2017/6/21.
//  Copyright © 2017年 从今以后. All rights reserved.
//

import UIKit

class UserCenterViewController: UITableViewController {

	private let animationDuration = 0.35
}

extension UserCenterViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		animate(cell: cell, for: indexPath)
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "show", sender: nil)
	}
}

extension UserCenterViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let label = tableView.lx_cellForSelectedRow()?.contentView.subviews.last as? UILabel {
			segue.destination.title = label.text
		}
	}
}

private extension UserCenterViewController {

    func animate(cell: UITableViewCell, for indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: tableView.rect(forSection: 0).height)
        UIView.animate(withDuration: animationDuration, delay: Double(indexPath.row) * 0.03, options: [], animations: {
            cell.transform = .identity
        })
    }
}
