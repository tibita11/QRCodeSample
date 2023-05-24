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

protocol QRCodeReaderViewModelOutput {
    var presentationDriver: Driver<String> { get }
    var isAuthorized: Driver<Bool> { get }
}

protocol QRCodeReaderViewModelType {
    var output: QRCodeReaderViewModelOutput! { get }
}

class QRCodeReaderViewModel: NSObject, QRCodeReaderViewModelType {
    var output: QRCodeReaderViewModelOutput! { self }
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectQueue = DispatchQueue(label: "metadataObjectQueue")
    private let presentationPublishRelay = PublishRelay<String>()
    private let isAuthorizedBehaviorRelay = BehaviorRelay(value: false)
    
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
            presentationPublishRelay.accept(stringValue)
        }
    }
}


// MARK: - QRCodeReaderViewModelOutput

extension QRCodeReaderViewModel: QRCodeReaderViewModelOutput {
    var presentationDriver: Driver<String> {
        presentationPublishRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    var isAuthorized: Driver<Bool> {
        isAuthorizedBehaviorRelay.asDriver(onErrorDriveWith: .empty())
    }
    
}
