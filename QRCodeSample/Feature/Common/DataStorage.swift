//
//  DataStorage.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/25.
//

import Foundation
import RealmSwift

class DataStorage {
    
    private let realm: Realm!
    
    init(realm: Realm) {
        self.realm = realm
    }
    
    func save(value: String) {
        let item = Item()
        item.title = value
        
        do {
            try realm.write {
                if let itemList = realm.objects(ItemList.self).first {
                    // そのまま追加
                    print("Listがあるよ")
                    itemList.list.append(item)
                } else {
                    // Listを作成して追加
                    print("Listがないよ")
                    let itemList = ItemList()
                    itemList.list.append(item)
                    realm.add(itemList)
                }
            }
        } catch (let error){
            print("Realm保存失敗: \(error.localizedDescription)")
        }
    }
}
