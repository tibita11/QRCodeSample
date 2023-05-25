//
//  QRCodeListViewModel.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/25.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

protocol QRCodeListViewModelOutput {
    var listObserver: Observable<List<Item>> { get }
}

protocol QRCodeListViewModelType {
    var output: QRCodeListViewModelOutput! { get }
}

class QRCodeListViewModel: QRCodeListViewModelType {
    var output: QRCodeListViewModelOutput! { self }
    
    private let listPublishRelay = PublishRelay<List<Item>>()
    private let disposeBag = DisposeBag()
    
    func setUp() {
        let realm = try! Realm()
        let itemList = realm.objects(ItemList.self)
        // データ取得
        Observable.array(from: itemList)
            .subscribe(onNext: { [weak self] itemList in
                guard let list = itemList.first?.list else {
                    return
                }
                // UI反映
                self?.listPublishRelay.accept(list)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - QRCodeListViewModelOutput

extension QRCodeListViewModel: QRCodeListViewModelOutput {
    var listObserver: Observable<List<Item>> {
        listPublishRelay.asObservable()
    }
}
