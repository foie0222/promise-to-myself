import Testing
import Foundation
@testable import PromiseToMyself

struct PromiseTests {
    @Test func createPromise() {
        let deadline = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "毎朝7時に起きる", deadline: deadline)

        #expect(promise.content == "毎朝7時に起きる")
        #expect(promise.deadline == deadline)
    }

    @Test func isExpired_beforeDeadline_returnsFalse() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)

        #expect(!promise.isExpired)
    }

    @Test func isExpired_afterDeadline_returnsTrue() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)

        #expect(promise.isExpired)
    }

    @Test func daysRemaining_sevenDaysFromNow() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)

        #expect(promise.daysRemaining >= 6 && promise.daysRemaining <= 7)
    }

    @Test func daysRemaining_pastDeadline_returnsZero() {
        let past = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)

        #expect(promise.daysRemaining == 0)
    }

    @Test func jsonRoundTrip() throws {
        let deadline = Date(timeIntervalSince1970: 1750000000)
        let original = Promise(content: "ギャンブルをやめる", deadline: deadline)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Promise.self, from: data)

        #expect(decoded.content == original.content)
        #expect(decoded.deadline == original.deadline)
    }
}
