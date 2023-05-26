//
//  QRCodeSampleTests.swift
//  QRCodeSampleTests
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import XCTest
import Photos
import RealmSwift
@testable import QRCodeSample

final class QRCodeGeneratorTests: XCTestCase {
    
    func testGenerateQRCode() {
        XCTContext.runActivity(named: "QRコードが作成されること") { _ in
            let image = QRCodeGeneratorViewModel().generateQRCode(value: "テスト")
            XCTAssertNotNil(image)
        }
    }
}


// MARK: - QRCodeReaderTests

final class QRCodeReaderTests: XCTestCase {
    
    func testDetectQRCode() {
        let qrCodeReaderViewModel = QRCodeReaderViewModel()
        
        XCTContext.runActivity(named: "QRコードが検出できること") { _ in
            guard let testImage = UIImage(named: "QRCodeTestImage") else { return }
            let message = qrCodeReaderViewModel.detectQRCode(from: testImage)
            XCTAssertEqual(message, "テスト")
        }
        
        XCTContext.runActivity(named: "QRコードが検出できないこと") { _ in
            guard let testImage = UIImage(systemName: "person.fill") else { return }
            let message = qrCodeReaderViewModel.detectQRCode(from: testImage)
            XCTAssertNil(message)
        }
    }
}


// MARK: - QRCodeAdditionTests

final class QRCodeAdditionTests: XCTestCase {
    private var dataStorage: DataStorage!
    private var realm: Realm!
    
    override func setUp() {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        realm = try! Realm()
        dataStorage = DataStorage(realm: realm)
    }
    
    func testSave() {
        XCTContext.runActivity(named: "初回保存の場合") { _ in
            dataStorage.save(value: "テスト1")
            // Itemに追加されていること
            let itemCount = realm.objects(Item.self).count
            XCTAssertEqual(itemCount, 1)
            // ItemsListに追加されていること
            guard let list = realm.objects(ItemList.self).first?.list, let firstItem = list.first else {
                XCTFail("DBへの登録が正しくありません。")
                return
            }
            XCTAssertEqual(list.count, 1)
            XCTAssertEqual(firstItem.title, "テスト1")
        }
        
        XCTContext.runActivity(named: "2回目保存の場合") { _ in
            dataStorage.save(value: "テスト2")
            // Itemに追加されていること
            let itemCount = realm.objects(Item.self).count
            XCTAssertEqual(itemCount, 2)
            // ItemsListに追加されていること
            guard let list = realm.objects(ItemList.self).first?.list, let firstItem = list.first, let lastItem = list.last else {
                XCTFail("DBへの登録が正しくありません。")
                return
            }
            XCTAssertEqual(list.count, 2)
            XCTAssertEqual(firstItem.title, "テスト1")
            XCTAssertEqual(lastItem.title, "テスト2")
        }
    }
}

final class QRCodeListTests: XCTestCase {
    private var dataStorage: DataStorage!
    private var realm: Realm!
    
    override func setUpWithError() throws {
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        realm = try! Realm()
        
        try realm.write {
            let itemList = ItemList()
            for number in 1...3 {
                let item = Item()
                item.title = "テスト\(number)"
                itemList.list.append(item)
            }
            realm.add(itemList)
        }
        dataStorage = DataStorage(realm: realm)
    }
    
    func testDelete() {
        XCTContext.runActivity(named: "ListとListItemのカウント数が一致していること") { _ in
            dataStorage.delete(at: 0)
            let item = realm.objects(Item.self)
            let itemList = realm.objects(ItemList.self).first!.list
            XCTAssertEqual(item.count, itemList.count)
        }
    }
    
    func testMove() {
        XCTContext.runActivity(named: "並び順が変更されていること") { _ in
            dataStorage.move(from: 0, to: 2)
            let itemList = realm.objects(ItemList.self).first!.list
            XCTAssertEqual(itemList[2].title, "テスト1")
        }
    }
    
    
}
