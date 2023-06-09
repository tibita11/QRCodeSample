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
                    itemList.list.append(item)
                } else {
                    // Listを作成して追加
                    let itemList = ItemList()
                    itemList.list.append(item)
                    realm.add(itemList)
                }
            }
        } catch (let error){
            print("Realm保存失敗: \(error.localizedDescription)")
        }
    }
    
    func delete(at index: Int) {
        if let list = realm.objects(ItemList.self).first?.list {
            let item = list[index]
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch (let error) {
                print("Realm削除失敗: \(error.localizedDescription)")
            }
        }
    }
    
    func move(from sourceIndex: Int, to destinationIndex: Int) {
        if let list = realm.objects(ItemList.self).first?.list {
            let item = list[sourceIndex]
            do {
                try realm.write {
                    list.remove(at: sourceIndex)
                    list.insert(item, at: destinationIndex)
                }
            } catch (let error) {
                print("Realm並び替え失敗: \(error.localizedDescription)")
            }
        }
    }
}
