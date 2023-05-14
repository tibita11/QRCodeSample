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

struct QRCodeGeneratorViewModelInput {
    let valueTextFieldObserver: Observable<String?>
}

protocol QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> { get }
    var qrCodeImageDriver: Driver<UIImage> { get }
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
        let uiImage = UIImage(ciImage: ciImage)
        qrCodeImageRelay.accept(uiImage)
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
    
    
}
