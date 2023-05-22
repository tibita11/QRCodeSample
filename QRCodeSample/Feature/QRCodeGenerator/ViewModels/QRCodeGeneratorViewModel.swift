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
import LinkPresentation

struct QRCodeGeneratorViewModelInput {
    let valueTextFieldObserver: Observable<String?>
}

protocol QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> { get }
    var alertPresentationDriver: Driver<UIAlertController> { get }
    var activityPresentationDriver: Driver<UIActivityViewController> { get }
}

protocol QRCodeGeneratorViewModelType {
    var output: QRCodeGeneratorViewModelOutput! { get }
    func setUp(input: QRCodeGeneratorViewModelInput)
}

class QRCodeGeneratorViewModel: QRCodeGeneratorViewModelType {
    var output: QRCodeGeneratorViewModelOutput! { return self }
    private let disposeBag = DisposeBag()
    private let qrCodeButtonIsEnabledRelay = PublishRelay<Bool>()
    private let alertPresentationRelay = PublishRelay<UIAlertController>()
    private let activityPresentationRelay = PublishRelay<UIActivityViewController>()
    
    func setUp(input: QRCodeGeneratorViewModelInput) {
        // 生成ボタンがタップ可能であるかを判断する
        input.valueTextFieldObserver
            .subscribe(onNext: { [weak self] value in
                guard let value = value else { return }
                self?.qrCodeButtonIsEnabledRelay.accept(value.count != 0)
            })
            .disposed(by: disposeBag)
    }
    
    func generateQRCode(value: String) -> UIImage? {
        // QRコード生成
        guard let data = value.data(using: .utf8),
              let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage" : data, "inputCorrectionLevel" : "M"]),
              let outputImage = qr.outputImage else { return nil }
        // 画像拡大
        let ciImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        // アルバム保存のためCGImageに変換
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// 保存実行後にUIに反映する
    func saveImageToAlbum(image: UIImage) {
        Task {
            let status = await checkStorageStatus(image: image)
            guard let status = status else { return }
            var alertController: UIAlertController!
            switch status {
            case .saved:
                alertController = createAlert()
            case .error(let error):
                alertController = createAlert(message: error.localizedDescription)
            case .goSettings:
                alertController = createSettingsAlert()
            }
            alertPresentationRelay.accept(alertController)
        }
    }
    
    /// 画像がアルバムに正しく保存できたかを判断する
    /// 保存処理をテストするためpublic
    func checkStorageStatus(image: UIImage) async -> StorageStatus? {
        var storageStatus:StorageStatus? = nil
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized:
            // 許可の場合に保存結果を取得
            let error = await saveImage(image: image)
            if let error = error {
                storageStatus = .error(error)
            } else {
                storageStatus = .saved
            }
        case .denied, .restricted, .limited:
            storageStatus = .goSettings
        case .notDetermined:
            // 許可の場合に保存結果を取得
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            if status == .authorized {
                let error = await saveImage(image: image)
                if let error = error {
                    storageStatus = .error(error)
                } else {
                    storageStatus = .saved
                }
            }
        @unknown default:
            break
        }
        return storageStatus
    }
    
    /// アルバムに保存する
    private func saveImage(image: UIImage) async -> Error? {
        var result: Error? = nil
        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch (let error) {
            result = error
        }
        return result
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
    
    /// シェア画面を作成して表示する
    func shareImage(image: UIImage) {
        let message = "[QRCodeSample] QRコードを読み込みグループを追加しましょう！"
        let linkMetaData = LPLinkMetadata()
        linkMetaData.title = message
        linkMetaData.imageProvider = NSItemProvider(object: image)
        let itemSource = ShareActivityItemSource(linkMetaData: linkMetaData)
        let shareItems = [image, message, itemSource] as [Any]
        let controller = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityPresentationRelay.accept(controller)
    }
    
    
}


// MARK: - QRCodeGeneratorViewModelOutput

extension QRCodeGeneratorViewModel: QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> {
        qrCodeButtonIsEnabledRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var alertPresentationDriver: Driver<UIAlertController> {
        alertPresentationRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var activityPresentationDriver: Driver<UIActivityViewController> {
        activityPresentationRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    
}


// MARK: - ShareActivityItemSource

class ShareActivityItemSource: NSObject, UIActivityItemSource {
    var linkMetaData = LPLinkMetadata()

    init(linkMetaData: LPLinkMetadata) {
        self.linkMetaData = linkMetaData
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
}


// MARK: - StorageStatus

enum StorageStatus {
    case saved
    case error(Error)
    case goSettings
}

