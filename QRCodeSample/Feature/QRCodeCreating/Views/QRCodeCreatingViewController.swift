//
//  QRCodeCreateViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import UIKit

class QRCodeCreatingViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            // 画像位置を変更
            var config = saveButton.configuration
            config?.imagePlacement = .top
            saveButton.configuration = config
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
