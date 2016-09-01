//
//  PayLessTaxUITests.swift
//  PayLessTaxUITests
//
//  Created by Sheena Moh on 11/08/2016.
//  Copyright © 2016 SMoh. All rights reserved.
//

import XCTest

class PayLessTaxUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testSnapHomeScreen() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["Reading Material"].tap()
        
        let scrollViewsQuery = app.scrollViews
        
        let receiptElement = XCUIApplication().scrollViews.otherElements.containingType(.Image, identifier:"receipt").element
        receiptElement.tap()
        snapshot("newRebateScreen")
        
        XCUIApplication().navigationBars["Reading Material"].buttons["Get Rebates"].tap()
        
        
//        let app = XCUIApplication()
//        
//        let alert = app.alerts["“PayLessTax” Would Like to Send You Notifications"]
//        let logoutButton = XCUIApplication().buttons["Logout"]
//        if  logoutButton.exists{
//            XCUIApplication().navigationBars["Get Rebates"].buttons["Logout"].tap()
//        }
//        
//        if alert.exists{
//            alert.collectionViews.buttons["OK"].tap()
//        }
//        
//        let elementsQuery = app.scrollViews.otherElements
//        let emailTextField = elementsQuery.textFields["Email"]
//        emailTextField.tap()
//        emailTextField.typeText("123@mail.com")
//        
//        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
//        passwordSecureTextField.tap()
//        passwordSecureTextField.typeText("123456")
//        
//        elementsQuery.buttons["Login now"].tap()
//        
//        sleep(4)
//        
//        snapshot("homeScreen")
//
//        app.tabBars.buttons["MyIncome"].tap()
//        snapshot("incomeScreen")
//        
//        app.tabBars.buttons["Summary"].tap()
//        snapshot("summaryScreen")
//
//        app.tabBars.buttons["Get Rebates"].tap()
//        XCUIApplication().navigationBars["Get Rebates"].buttons["Logout"].tap()
    }
    
    func newRebate() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["Reading Material"].tap()
        
        let scrollViewsQuery = app.scrollViews
        scrollViewsQuery.otherElements.containingType(.Image, identifier:"receipt").childrenMatchingType(.Other).elementBoundByIndex(1).tap()
//        scrollViewsQuery.otherElements.containingType(.Image, identifier:"receipt").element.tap()
        
        XCUIApplication().navigationBars["Reading Material"].buttons["Get Rebates"].tap()
        snapshot("newRebateScreen")
        
    }
    
//    func testSnapIncomeScreen() {
//        
//        XCUIApplication().navigationBars["Get Rebates"].buttons["Logout"].tap()
//        
//        
//        let app = XCUIApplication()
//        let elementsQuery = app.scrollViews.otherElements
//        let emailTextField = elementsQuery.textFields["Email"]
//        emailTextField.tap()
//        emailTextField.typeText("123@mail.com")
//        
//        let passwordSecureTextField = elementsQuery.secureTextFields["Password"]
//        passwordSecureTextField.tap()
//        passwordSecureTextField.typeText("123456")
//        
//        elementsQuery.buttons["Login now"].tap()
//        app.tabBars.buttons["MyIncome"].tap()
//        snapshot("incomeScreen")
//        
//        XCUIApplication().tabBars.buttons["Get Rebates"].tap()
//    }
    
    
}
