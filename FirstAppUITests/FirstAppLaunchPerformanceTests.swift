import XCTest

final class FirstAppLaunchPerformanceTests:
    XCTestCase {

    func testLaunchPerformance() {
        measure(
            metrics: [
                XCTApplicationLaunchMetric()
            ]
        ) {
            let app =
                XCUIApplication()

            app.launchArguments = [
                "--ui-testing"
            ]

            app.launch()
        }
    }
}
