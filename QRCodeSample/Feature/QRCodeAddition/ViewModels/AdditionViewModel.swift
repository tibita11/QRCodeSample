//
//  AdditionViewModel.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/25.
//

import Foundation
import RealmSwift


class AdditionViewModel {
    func save(value: String) {
        let reaml = try! Realm()
        let dataStorage = DataStorage(realm: reaml)
        dataStorage.save(value: value)
    }
}
