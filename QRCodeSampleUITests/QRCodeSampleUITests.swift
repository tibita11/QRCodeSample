//
//  QRCodeSampleUITests.swift
//  QRCodeSampleUITests
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import XCTest

final class QRCodeSampleUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShareImage() {
        // タブ移動
        let tabBar = app.tabBars.firstMatch
        let tabIndex = 1
        let tab = tabBar.buttons.element(boundBy: tabIndex)
        tab.tap()
        // 指定のViewControllerが表示されていること
        let qrCodeGeneratorViewController = app.otherElements["qrCodeGeneratorViewController"]
        XCTAssertTrue(qrCodeGeneratorViewController.waitForExistence(timeout: 3))
        // UI要素の検索
        let qrCodeValueTextField = app.textFields["qrCodeValueTextField"]
        let qrCodeButton = app.buttons["qrCodeButton"]
        let shareButton = app.buttons["shareButton"]
        // UI要素の検証
        XCTAssert(qrCodeValueTextField.exists)
        XCTAssert(qrCodeButton.exists)
        XCTAssertFalse(qrCodeButton.isEnabled)
        XCTAssert(shareButton.exists)
        XCTAssertFalse(shareButton.isEnabled)
        // テキスト入力
        qrCodeValueTextField.tap()
        qrCodeValueTextField.typeText("テスト")
        qrCodeValueTextField.typeText("\n")
        // ボタンがタップ可能であること
        XCTAssert(qrCodeButton.isEnabled)
        qrCodeButton.tap()
        // シェアボタンがタップ可能であること
        XCTAssert(shareButton.isEnabled)
        shareButton.tap()
        // ActivityViewControllerが表示されていること
        let activityListView = app.otherElements.element(matching: .other, identifier: "ActivityListView")
        XCTAssert(activityListView.waitForExistence(timeout: 3))
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
