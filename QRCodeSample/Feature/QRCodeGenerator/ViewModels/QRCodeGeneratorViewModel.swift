//
//  QRCodeCreatingViewModel.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/13.
//

import Foundation
import RxSwift
import RxCocoa
import CoreImage
import Photos

struct QRCodeGeneratorViewModelInput {
    let valueTextFieldObserver: Observable<String?>
}

protocol QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> { get }
    var qrCodeImageDriver: Driver<UIImage> { get }
    var alertPresentationDriver: Driver<UIAlertController> { get }
}

protocol QRCodeGeneratorViewModelType {
    var output: QRCodeGeneratorViewModelOutput! { get }
    func setUp(input: QRCodeGeneratorViewModelInput)
}

class QRCodeGeneratorViewModel: QRCodeGeneratorViewModelType {
    var output: QRCodeGeneratorViewModelOutput! { return self }
    private let disposeBag = DisposeBag()
    private let qrCodeButtonIsEnabledRelay = PublishRelay<Bool>()
    private let qrCodeImageRelay = PublishRelay<UIImage>()
    private let alertPresentationRelay = PublishRelay<UIAlertController>()
    
    func setUp(input: QRCodeGeneratorViewModelInput) {
        // 生成ボタンがタップ可能であるかを判断する
        input.valueTextFieldObserver
            .subscribe(onNext: { [weak self] value in
                guard let value = value else { return }
                self?.qrCodeButtonIsEnabledRelay.accept(value.count != 0)
            })
            .disposed(by: disposeBag)
    }
    
    func generateQRCode(value: String) {
        // UIに表示するQRCodeを生成し、反映する
        guard let data = value.data(using: .utf8) else { return }
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage" : data, "inputCorrectionLevel" : "M"])!
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let ciImage = qr.outputImage!.transformed(by: transform)
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        let uiImage = UIImage(cgImage: cgImage)
        qrCodeImageRelay.accept(uiImage)
    }
    
    func saveImageToAlbum(image: UIImage) {
        // 保存後に処理結果をアラートにて表示
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .authorized:
                self.saveImage(image: image)
            case .denied, .restricted, .limited:
                // 設定画面に促す
                self.alertPresentationRelay.accept(self.createSettingsAlert())
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    if status == .authorized {
                        self.saveImage(image: image)
                    }
                }
                break
            @unknown default:
                break
            }
        }
    }
    
    private func saveImage(image: UIImage) {
        // アルバムに画像を保存する
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { [weak self] success, error in
            guard let self = self else { return }
            // アラートをUIに表示する
            DispatchQueue.main.async {
                if success {
                    self.alertPresentationRelay.accept(self.createAlert())
                } else if let error = error {
                    self.alertPresentationRelay.accept(self.createAlert(message: error.localizedDescription))
                }
            }
        }
    }
    
    private func createAlert(message: String? = nil) -> UIAlertController {
        let message = message ?? "QRコードをアルバムに保存しました。"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default)
        alertController.addAction(okAction)
        return alertController
    }
    
    private func createSettingsAlert() -> UIAlertController {
        let message = "端末の[設定]>[QRCodeSample]で、アルバムへのアクセスを許可してください。"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        let settingsAction = UIAlertAction(title: "設定", style: .default) { _ in
            // 設定画面へ移動
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        return alertController
    }
    
    
}


// MARK: - QRCodeGeneratorViewModelOutput

extension QRCodeGeneratorViewModel: QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> {
        qrCodeButtonIsEnabledRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var qrCodeImageDriver: Driver<UIImage> {
        qrCodeImageRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var alertPresentationDriver: Driver<UIAlertController> {
        alertPresentationRelay.asDriver(onErrorDriveWith: .empty())
    }
    
}
