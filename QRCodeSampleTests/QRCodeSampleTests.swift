//
//  QRCodeSampleTests.swift
//  QRCodeSampleTests
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import XCTest
import Photos
@testable import QRCodeSample

final class QRCodeGeneratorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGenerateQRCode() {
        XCTContext.runActivity(named: "QRコードが作成されること") { _ in
            let image = QRCodeGeneratorViewModel().generateQRCode(value: "テスト")
            XCTAssertNotNil(image)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
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
