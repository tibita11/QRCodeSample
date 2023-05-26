//
//  SectionOfItemData.swift
//  QRCodeSample
//
//  Created by 鈴木楓香 on 2023/05/26.
//

import Foundation
import RxDataSources

struct SectionOfItemData {
    var items: [ItemData]
}

extension SectionOfItemData: SectionModelType {
    init(original: SectionOfItemData, items: [ItemData]) {
        self = original
        self.items = items
    }
}


 
