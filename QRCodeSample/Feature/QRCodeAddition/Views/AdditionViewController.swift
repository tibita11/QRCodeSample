//
//  AdditionalViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/23.
//

import UIKit

class AdditionViewController: UIViewController {

    @IBOutlet weak var valueLabel: UILabel!
    private let valueString: String!
    private let viewModel = AdditionViewModel()
    
    init(value: String) {
        self.valueString = value
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valueLabel.text = valueString
    }
    
    @IBAction func tapNoButton(_ sender: Any) {
        // 前の画面に戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapYesButton(_ sender: Any) {
        // DBに保存
        viewModel.save(value: valueString)
        // 一覧へ遷移
        if let rootViewController = navigationController?.viewControllers.first as? MainTabBarController {
            rootViewController.selectedIndex = 0
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
