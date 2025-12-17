import XCTest
import ISS

final class ISSSpaceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        iss_testing_enable()
        XCTAssertTrue(iss_testing_set_space_state(1, 3))
    }

    override func tearDown() {
        iss_testing_disable()
        super.tearDown()
    }

    func testCanMoveReportsAvailableDirections() throws {
        var info = ISSSpaceInfo()
        XCTAssertTrue(iss_get_space_info(&info))
        XCTAssertTrue(iss_can_move(info, ISSDirectionLeft))
        XCTAssertTrue(iss_can_move(info, ISSDirectionRight))

        XCTAssertTrue(iss_switch(ISSDirectionLeft))
        XCTAssertTrue(iss_get_space_info(&info))
        XCTAssertFalse(iss_can_move(info, ISSDirectionLeft))
        XCTAssertTrue(iss_can_move(info, ISSDirectionRight))
    }

    func testSwitchRespectsBounds() {
        var info = ISSSpaceInfo()
        XCTAssertTrue(iss_get_space_info(&info))

        XCTAssertTrue(iss_switch(ISSDirectionLeft))
        XCTAssertTrue(iss_get_space_info(&info))
        XCTAssertEqual(info.currentIndex, 0)

        XCTAssertFalse(iss_switch(ISSDirectionLeft))
        XCTAssertTrue(iss_switch(ISSDirectionRight))
        XCTAssertTrue(iss_get_space_info(&info))
        XCTAssertEqual(info.currentIndex, 1)
    }

    func testSwitchToIndexTargetsExpectedSpace() {
        XCTAssertTrue(iss_switch_to_index(2))
        var info = ISSSpaceInfo()
        XCTAssertTrue(iss_get_space_info(&info))
        XCTAssertEqual(info.currentIndex, 2)

        XCTAssertFalse(iss_switch_to_index(5))
        XCTAssertTrue(iss_get_space_info(&info))
        XCTAssertEqual(info.currentIndex, 2)
    }
}
