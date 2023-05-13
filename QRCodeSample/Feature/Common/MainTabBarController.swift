//
//  MainTabBarController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/12.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTab()
    }
    
    private func setUpTab() {
        let qrCodeListVC = QRCodeListViewController()
        qrCodeListVC.tabBarItem = UITabBarItem(title: "一覧", image: UIImage(systemName: "list.bullet"), tag: 0)
        let qrCodeCreatingVC = QRCodeGeneratorViewController()
        qrCodeCreatingVC.tabBarItem = UITabBarItem(title: "生成", image: UIImage(systemName: "qrcode"), tag: 0)
        let qrCodeReadingVC = QRCodeReadingViewController()
        qrCodeReadingVC.tabBarItem = UITabBarItem(title: "読み取り", image: UIImage(systemName: "qrcode.viewfinder"), tag: 0)
        
        viewControllers = [qrCodeListVC, qrCodeCreatingVC, qrCodeReadingVC]
    }
    
}
