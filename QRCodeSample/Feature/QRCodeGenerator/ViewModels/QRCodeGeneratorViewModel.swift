//
//  QRCodeCreatingViewModel.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/13.
//

import Foundation
import RxSwift
import RxCocoa

struct QRCodeGeneratorViewModelInput {
    let valueTextFieldObserver: Observable<String?>
}

protocol QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> { get }
}

protocol QRCodeGeneratorViewModelType {
    var output: QRCodeGeneratorViewModelOutput! { get }
    func setUp(input: QRCodeGeneratorViewModelInput)
}

class QRCodeGeneratorViewModel: QRCodeGeneratorViewModelType {
    var output: QRCodeGeneratorViewModelOutput! { return self }
    private let disposeBag = DisposeBag()
    private let qrCodeButtonIsEnabledRelay = PublishRelay<Bool>()
    
    func setUp(input: QRCodeGeneratorViewModelInput) {
        // 生成ボタンがタップ可能であるかを判断する
        input.valueTextFieldObserver
            .subscribe(onNext: { [weak self] value in
                guard let value = value else { return }
                self?.qrCodeButtonIsEnabledRelay.accept(value.count != 0)
            })
            .disposed(by: disposeBag)
    }
    
    
}


// MARK: - QRCodeGeneratorViewModelOutput

extension QRCodeGeneratorViewModel: QRCodeGeneratorViewModelOutput {
    var qrCodeButtonIsEnabledDriver: Driver<Bool> {
        qrCodeButtonIsEnabledRelay.asDriver(onErrorDriveWith: .empty())
    }
    
    
}
