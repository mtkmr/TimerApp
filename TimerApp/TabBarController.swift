//
//  TabBarController.swift
//  TimerApp
//
//  Created by Masato Takamura on 2021/09/26.
//

import UIKit

enum Tab: Int {
    case timer = 0
}

final class TabBarController: UITabBarController {

    private lazy var timerVC: TimerViewController = {
        let timerVC = TimerViewController()
        timerVC.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "timer"),
            tag: Tab.timer.rawValue
        )
        return timerVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        setupTabBar()
    }

    private func setupTabBar() {
        viewControllers = [
            timerVC
        ]
        tabBar.tintColor = .systemTeal
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.barTintColor = .clear
        tabBar.isTranslucent = false
    }


}
