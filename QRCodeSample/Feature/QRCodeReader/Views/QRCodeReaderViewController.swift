//
//  QRCodeReadingViewController.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/12.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class QRCodeReaderViewController: UIViewController {
    
    @IBOutlet weak var preview: UIView!
    private let viewModel = QRCodeReaderViewModel()
    private let disposeBag = DisposeBag()
    /// カメラの映像
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.viewModel.session)
            layer.frame = preview.bounds
            layer.videoGravity = .resizeAspectFill
            layer.connection?.videoOrientation = .portrait
            return layer
        }()
    /// アクセス拒否の場合に表示するView
    private lazy var settingsView: SettingsView = {
       let settingsView = SettingsView()
        settingsView.frame = preview.bounds
        return settingsView
    }()
    
    
    // MARK: - View Lify cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        viewModel.checkAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.stopSession()
    }
    
    
    // MARK: - Action
    
    private func setUp() {
        // QRコード取得後の遷移処理
        viewModel.output.presentationDriver
            .drive(onNext: { [weak self] stringValue in
                let additionalVC = AdditionalViewController(value: stringValue)
                self?.parent?.navigationController?.pushViewController(additionalVC, animated: true)
            })
            .disposed(by: disposeBag)
        // 許可状態に応じて画面の表示を切り替える
        viewModel.output.isAuthorizedDriver
            .skip(1)
            .drive(onNext: { [weak self] bool in
                guard let self = self else { return }
                bool ? self.preview.layer.addSublayer(self.previewLayer) : self.preview.addSubview(settingsView)
                self.viewModel.startSession()
            })
            .disposed(by: disposeBag)
    }
}
