//
//  QRCodeReaderViewModel.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/23.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa
import PhotosUI

struct QRCodeReaderViewModelInput {
    let albumButtonObaserver: Observable<Void>
}

protocol QRCodeReaderViewModelOutput {
    var transitionDriver: Driver<String> { get }
    var isAuthorizedDriver: Driver<Bool> { get }
    var phpickerPresentationDriver: Driver<PHPickerViewController> { get }
    var errorAlertPresentationDriver: Driver<UIAlertController> { get }
}

protocol QRCodeReaderViewModelType {
    var output: QRCodeReaderViewModelOutput! { get }
    func setUp(input: QRCodeReaderViewModelInput)
}

class QRCodeReaderViewModel: NSObject, QRCodeReaderViewModelType {
    var output: QRCodeReaderViewModelOutput! { self }
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectQueue = DispatchQueue(label: "metadataObjectQueue")
    private let transitionPublishRelay = PublishRelay<String>()
    private let isAuthorizedBehaviorRelay = BehaviorRelay(value: false)
    private let phpickerPresentationPublishRelay = PublishRelay<PHPickerViewController>()
    private let errorAlertPresentationPublishRelay = PublishRelay<UIAlertController>()
    private let disposeBag = DisposeBag()
    
    func setUp(input: QRCodeReaderViewModelInput) {
        // アルバム表示
        input.albumButtonObaserver
            .subscribe(onNext: { [weak self] in
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self?.phpickerPresentationPublishRelay.accept(picker)
            })
            .disposed(by: disposeBag)
    }
    
    func checkAuthorization() {
        Task {
            var isAuthorized: Bool = false
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                // session準備・カメラ表示
                sessionQueue.sync { [weak self] in
                    self?.configureSession()
                }
                isAuthorized = true
            case .restricted, .denied:
                break
            case .notDetermined:
                let bool = await AVCaptureDevice.requestAccess(for: .video)
                if bool {
                    sessionQueue.sync {
                        configureSession()
                    }
                    isAuthorized = bool
                }
            @unknown default:
                break
            }
            // UIに反映
            isAuthorizedBehaviorRelay.accept(isAuthorized)
        }
    }
    
    /// AVCaptureSessionの初期化
    private func configureSession() {
        session.beginConfiguration()
        // Device取得
        let defaultVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                         for: .video,
                                                         position: .back)
        guard let videoDevice = defaultVideoDevice else {
            self.configureSession()
            return
        }
        // Sessionに追加
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            }
        } catch {
            session.commitConfiguration()
            return
        }
        // QR検知のためのOutput
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: metadataObjectQueue)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            session.commitConfiguration()
        }
        // 設定完了
        session.commitConfiguration()
    }
    
    /// QRコード読み取り開始
    func startSession() {
        // アクセス許可されている場合にのみ起動
        if isAuthorizedBehaviorRelay.value {
            sessionQueue.async { [weak self] in
                self?.session.startRunning()
            }
        }
    }
    
    /// QRコード読み取り終了
    func stopSession() {
        if session.isRunning {
            sessionQueue.async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    /// 画像からQRコードを検出
    /// - Returns: 取得した文字列
    func detectQRCode(from image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }
        // 検出
        let context = CIContext()
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage)
        // 文字列取得
        if let fisetFeature = features?.first as? CIQRCodeFeature {
            return fisetFeature.messageString
        }
        return nil
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: nil, message: "QRコードが検出できません。\n他の写真を選択してください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        // UI表示
        errorAlertPresentationPublishRelay.accept(alertController)
    }
    
}


// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRCodeReaderViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // QRコードの情報取得
        for metedataObject in metadataObjects {
            guard let machineReadableCode = metedataObject as? AVMetadataMachineReadableCodeObject,
                  machineReadableCode.type == .qr,
                  let stringValue = machineReadableCode.stringValue else {
                return
            }
            // 次の画面に遷移する
            transitionPublishRelay.accept(stringValue)
        }
    }
}


// MARK: - PHPickerViewControllerDelegate

extension QRCodeReaderViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        guard let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            showErrorAlert()
            return
        }
        // 画像取得
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard error == nil else{
                self?.showErrorAlert()
                return
            }
            // QRコード検出
            guard let image = image, let uiImage = image as? UIImage, let message = self?.detectQRCode(from: uiImage) else {
                self?.showErrorAlert()
                return
            }
            // 文字列取得成功
            self?.transitionPublishRelay.accept(message)
        }
    }
}


// MARK: - QRCodeReaderViewModelOutput

extension QRCodeReaderViewModel: QRCodeReaderViewModelOutput {
    var transitionDriver: Driver<String> {
        transitionPublishRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var isAuthorizedDriver: Driver<Bool> {
        isAuthorizedBehaviorRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var phpickerPresentationDriver: Driver<PHPickerViewController> {
        phpickerPresentationPublishRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var errorAlertPresentationDriver: Driver<UIAlertController> {
        errorAlertPresentationPublishRelay.asDriver(onErrorDriveWith: .empty())
    }
    
}
