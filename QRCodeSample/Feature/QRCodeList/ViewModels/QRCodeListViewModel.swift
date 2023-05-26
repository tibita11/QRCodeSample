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
    var listObserver: Observable<[SectionOfItemData]> { get }
}

protocol QRCodeListViewModelType {
    var output: QRCodeListViewModelOutput! { get }
}

class QRCodeListViewModel: QRCodeListViewModelType {
    var output: QRCodeListViewModelOutput! { self }
    
    private let listPublishRelay = PublishRelay<[SectionOfItemData]>()
    private let disposeBag = DisposeBag()
    private var realm: Realm!
    private lazy var dataSotrage: DataStorage = {
        let dataSotrage = DataStorage(realm: self.realm)
        return dataSotrage
    }()
    
    func setUp() {
        realm = try! Realm()
        let itemList = realm.objects(ItemList.self)
        // データ取得
        Observable.array(from: itemList)
            .subscribe(onNext: { [weak self] itemList in
                guard let itemList = itemList.first?.list else {
                    return
                }
                let list: [ItemData] = itemList.map({ ItemData(title: $0.title) })
                let section = SectionOfItemData(items: list)
                self?.listPublishRelay.accept([section])
            })
            .disposed(by: disposeBag)
    }
    
    func delete(at index: Int) {
        dataSotrage.delete(at: index)
    }
    
    func move(from sourceIndex: Int, to destinationIndex: Int) {
        dataSotrage.move(from: sourceIndex, to: destinationIndex)
    }
}


// MARK: - QRCodeListViewModelOutput

extension QRCodeListViewModel: QRCodeListViewModelOutput {
    var listObserver: Observable<[SectionOfItemData]> {
        listPublishRelay.asObservable()
    }
}
