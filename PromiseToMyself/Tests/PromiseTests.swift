import XCTest
@testable import PromiseToMyself

final class PromiseTests: XCTestCase {
    func testCreatePromise() {
        let deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "毎朝7時に起きる", deadline: deadline)

        XCTAssertEqual(promise.content, "毎朝7時に起きる")
        XCTAssertEqual(promise.deadline, deadline)
    }

    func testIsExpired_beforeDeadline_returnsFalse() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)

        XCTAssertFalse(promise.isExpired)
    }

    func testIsExpired_afterDeadline_returnsTrue() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)

        XCTAssertTrue(promise.isExpired)
    }

    func testDaysRemaining_sevenDaysFromNow() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)

        XCTAssertTrue(promise.daysRemaining >= 6 && promise.daysRemaining <= 7)
    }

    func testDaysRemaining_pastDeadline_returnsZero() {
        let past = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)

        XCTAssertEqual(promise.daysRemaining, 0)
    }

    func testJsonRoundTrip() throws {
        let deadline = Date(timeIntervalSince1970: 1750000000)
        let original = Promise(content: "ギャンブルをやめる", deadline: deadline)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Promise.self, from: data)

        XCTAssertEqual(decoded.content, original.content)
        XCTAssertEqual(decoded.deadline, original.deadline)
    }
}
