import XCTest

final class FirstAppUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing"
        ]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testAddsGoal() throws {
        openGoalsTab()

        XCTAssertTrue(
            app.staticTexts["No Goals"]
                .waitForExistence(timeout: 3)
        )

        addGoal(named: "Meditate")

        XCTAssertTrue(
            app.staticTexts["Meditate"]
                .waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            app.staticTexts["0 of 5"].exists
        )
    }

    func testCancelDoesNotAddGoal() throws {
        openGoalsTab()

        let addButton = app.buttons["addGoalButton"]

        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3)
        )

        addButton.tap()

        let titleField =
            app.textFields["goalTitleField"]

        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3)
        )

        titleField.tap()
        titleField.typeText("Discarded Goal")

        app.buttons["cancelAddGoalButton"].tap()

        XCTAssertFalse(
            app.staticTexts["Discarded Goal"].exists
        )

        XCTAssertTrue(
            app.staticTexts["No Goals"]
                .waitForExistence(timeout: 3)
        )
    }

    func testEditsGoal() throws {
        openGoalsTab()
        addGoal(named: "Meditate")

        let goalTitle = app.staticTexts["Meditate"]

        XCTAssertTrue(
            goalTitle.waitForExistence(timeout: 3)
        )

        goalTitle.tap()

        let detailTitleField =
            app.textFields["goalDetailTitleField"]

        XCTAssertTrue(
            detailTitleField.waitForExistence(
                timeout: 3
            )
        )

        detailTitleField.tap()
        detailTitleField.typeKey(
            "a",
            modifierFlags: .command
        )
        detailTitleField.typeText("Meditate Daily")

        let increaseButton =
            app.buttons["goalDetailIncreaseButton"]

        if !increaseButton.waitForExistence(timeout: 1) {
            app.swipeUp()
        }

        XCTAssertTrue(
            increaseButton.waitForExistence(
                timeout: 3
            )
        )

        increaseButton.tap()

        let saveButton =
            app.buttons["saveGoalButton"]

        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        XCTAssertTrue(
            app.staticTexts["Meditate Daily"]
                .waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            app.staticTexts["1 of 5"].exists
        )
    }

    private func openGoalsTab() {
        let goalsTab =
            app.tabBars.buttons["Goals"]

        XCTAssertTrue(
            goalsTab.waitForExistence(timeout: 3)
        )

        goalsTab.tap()
    }

    private func addGoal(named title: String) {
        let addButton = app.buttons["addGoalButton"]

        XCTAssertTrue(
            addButton.waitForExistence(timeout: 3)
        )

        addButton.tap()

        let titleField =
            app.textFields["goalTitleField"]

        XCTAssertTrue(
            titleField.waitForExistence(timeout: 3)
        )

        titleField.tap()
        titleField.typeText(title)

        let confirmButton =
            app.buttons["confirmAddGoalButton"]

        XCTAssertTrue(confirmButton.isEnabled)
        confirmButton.tap()
    }
}
