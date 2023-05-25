//
//  ItemModel.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/25.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String
}

class ItemList: Object {
    @Persisted var list: List<Item>
}


