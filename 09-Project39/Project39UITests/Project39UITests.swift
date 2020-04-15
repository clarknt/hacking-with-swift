//
//  Project39UITests.swift
//  Project39UITests
//
//  Created by clarknt on 2020-04-08.
//  Copyright © 2020 clarknt. All rights reserved.
//

import XCTest

class Project39UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialStateIsCorrect() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially")
    }

    func testUserFilteringByString() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["Search"].tap()

        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("test")

        filterAlert.buttons["Filter"].tap()

        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching 'test'")
    }

    // challenge 1
    func testUserFilteringByNumber() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["Search"].tap()

        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("1000")

        filterAlert.buttons["Filter"].tap()

        XCTAssertEqual(app.tables.cells.count, 55, "There should be 55 words occuring 1000 times or more")
    }

    // challenge 2
    func testCancelUserFiltering() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        app.buttons["Search"].tap()

        let filterAlert = app.alerts
        filterAlert.buttons["Cancel"].tap()

        print(app.alerts.count)
        XCTAssertEqual(app.alerts.count, 0, "There should be no alert visible")
    }
}
