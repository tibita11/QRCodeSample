//
//  QRCodeCreateViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import UIKit
import RxSwift
import RxCocoa

class QRCodeGeneratorViewController: UIViewController {

    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            // 画像位置を変更
            saveButton.configuration = .filled()
            var config = saveButton.configuration
            config?.imagePlacement = .top
            saveButton.configuration = config
        }
    }
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
            // 画像位置を変更
            shareButton.configuration = .filled()
            var config = shareButton.configuration
            config?.imagePlacement = .top
            shareButton.configuration = config
        }
    }
    @IBOutlet weak var qrCodeButton: UIButton!
    
    private let viewModel = QRCodeGeneratorViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let input = QRCodeGeneratorViewModelInput(valueTextFieldObserver: valueTextField.rx.text.asObservable())
        viewModel.setUp(input: input)
        // QRCodeボタン
        viewModel.output.qrCodeButtonIsEnabledDriver
            .drive(qrCodeButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Action

    @IBAction func tapQRCodeButton(_ sender: Any) {
        print("生成します。")
    }
}
