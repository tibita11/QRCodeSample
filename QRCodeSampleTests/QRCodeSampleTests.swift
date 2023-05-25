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
