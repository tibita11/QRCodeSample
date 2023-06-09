//
//  QRCodeSampleUITests.swift
//  QRCodeSampleUITests
//
//  Created by 鈴木楓香 on 2023/05/11.
//

import XCTest

final class QRCodeGeneratorUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        app.resetAuthorizationStatus(for: .photos)
        app.resetAuthorizationStatus(for: .camera)
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShareImage() {
        generateQRCode()
        let shareButton = app.buttons["shareButton"]
        XCTAssert(shareButton.exists)
        
        XCTContext.runActivity(named: "画像をシェアできること") { _ in
            // シェアボタンがタップ可能であること
            XCTAssert(shareButton.isEnabled)
            shareButton.tap()
            // ActivityViewControllerが表示されていること
            let activityListView = app.otherElements.element(matching: .other, identifier: "ActivityListView")
            XCTAssert(activityListView.waitForExistence(timeout: 5))
            activityListView.buttons["Close"].tap()
        }
    }
    
    func testSaveImageAtFiestTime() {
        generateQRCode()
        let saveButton = app.buttons["saveButton"]
        XCTAssert(saveButton.exists)
        
        XCTContext.runActivity(named: "画像を保存できること") { _ in
            // 保存ボタンがタップ可能であること
            XCTAssert(saveButton.isEnabled)
            saveButton.tap()
            // アルバムの使用を許可に変更する
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            XCTAssert(springboard.waitForExistence(timeout: 5))
            springboard.buttons["すべての写真へのアクセスを許可"].tap()
            // 保存完了アラートが表示されていること
            let completionAlert = app.alerts.firstMatch
            XCTAssert(completionAlert.waitForExistence(timeout: 5))
            completionAlert.buttons["はい"].tap()
        }
    }
    
    func testTransitionToSettings() {
        generateQRCode()
        let saveButton = app.buttons["saveButton"]
        XCTAssert(saveButton.exists)
        
        XCTContext.runActivity(named: "拒否の場合に設定画面へ遷移できること") { _ in
            // 保存ボタンがタップ可能であること
            XCTAssert(saveButton.isEnabled)
            saveButton.tap()
            // アルバムの使用を許可しないに変更する
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            XCTAssert(springboard.waitForExistence(timeout: 5))
            springboard.buttons["許可しない"].tap()
            // 設定画面へ遷移
            saveButton.tap()
            let settingsAlert = app.alerts.firstMatch
            XCTAssert(settingsAlert.waitForExistence(timeout: 5))
            settingsAlert.buttons["設定"].tap()
            // 設定画面が表示されていること
            let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
            XCTAssert(settings.navigationBars["QRCodeSample"].waitForExistence(timeout: 5))
            // アプリへ戻る
            let backButton = springboard.statusBars.buttons["QRCodeSampleへ戻る"]
            XCTAssert(backButton.exists)
            backButton.tap()
            
        }
    }
    
    private func generateQRCode() {
        // タブ移動
        let tabBar = app.tabBars.firstMatch
        let tabIndex = 1
        let tab = tabBar.buttons.element(boundBy: tabIndex)
        tab.tap()
        // 指定のViewControllerが表示されていること
        let qrCodeGeneratorViewController = app.otherElements["qrCodeGeneratorViewController"]
        XCTAssertTrue(qrCodeGeneratorViewController.waitForExistence(timeout: 5))
        // UI要素の検索
        let qrCodeValueTextField = app.textFields["qrCodeValueTextField"]
        let qrCodeButton = app.buttons["qrCodeButton"]
        // UI要素の検証
        XCTAssert(qrCodeValueTextField.exists)
        XCTAssert(qrCodeButton.exists)
        XCTAssertFalse(qrCodeButton.isEnabled)
        // テキスト入力
        qrCodeValueTextField.tap()
        qrCodeValueTextField.typeText("テスト")
        qrCodeValueTextField.typeText("\n")
        // ボタンがタップ可能であること
        XCTAssert(qrCodeButton.isEnabled)
        qrCodeButton.tap()
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


// MARK: - QRCodeReaderUITests

final class QRCodeReaderUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        app.resetAuthorizationStatus(for: .camera)
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testShowVideoPreview() {
        XCTContext.runActivity(named: "アクセスを許可した場合に、プレビューのみが表示されていること") { _ in
            moveToTargetTab()
            // アクセス許可
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            XCTAssert(springboard.waitForExistence(timeout: 5))
            springboard.buttons["OK"].tap()
            // プレビューが表示されていること
            let preview = app.otherElements["preview"]
            XCTAssert(preview.exists)
            // 設定画面が表示されていないこと
            let settingsView = app.otherElements["settingsView"]
            XCTAssertFalse(settingsView.exists)
        }
    }
    
    func testShowSettingsView() {
        XCTContext.runActivity(named: "アクセス拒否した場合に、設定画面が表示されていること") { _ in
            moveToTargetTab()
            // アクセス許可
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            XCTAssert(springboard.waitForExistence(timeout: 5))
            springboard.buttons["許可しない"].tap()
            // プレビューが表示されていること
            let preview = app.otherElements["preview"]
            XCTAssert(preview.exists)
            // 設定画面が表示されていること
            let settingsView = app.otherElements["settingsView"]
            XCTAssert(settingsView.exists)
        }
    }
    
    private func moveToTargetTab() {
        // タブ移動
        let tabBar = app.tabBars.firstMatch
        let tabIndex = 2
        let tab = tabBar.buttons.element(boundBy: tabIndex)
        tab.tap()
        // 指定のViewControllerが表示されていること
        let qrCodeReaderViewController = app.otherElements["qrCodeReaderViewController"]
        XCTAssert(qrCodeReaderViewController.waitForExistence(timeout: 5))
    }
}
