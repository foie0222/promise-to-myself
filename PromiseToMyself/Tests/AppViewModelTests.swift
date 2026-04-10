import XCTest
@testable import PromiseToMyself

final class AppViewModelTests: XCTestCase {
    private func makeVM(
        isFirstLaunch: Bool = false,
        savedPromise: Promise? = nil
    ) -> AppViewModel {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return AppViewModel(
            isFirstLaunch: isFirstLaunch,
            savedPromise: savedPromise,
            userDefaults: defaults
        )
    }

    func testInitialState_firstLaunch_showsOnboarding() {
        let vm = makeVM(isFirstLaunch: true)
        XCTAssertEqual(vm.currentScreen, .onboarding)
    }

    func testInitialState_noPromise_showsInput() {
        let vm = makeVM()
        XCTAssertEqual(vm.currentScreen, .input)
    }

    func testInitialState_activePromise_showsDisplay() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: future))
        XCTAssertEqual(vm.currentScreen, .display)
    }

    func testInitialState_expiredPromise_showsCheck() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        XCTAssertEqual(vm.currentScreen, .check)
    }

    func testCompleteOnboarding_transitionsToInput() {
        let vm = makeVM(isFirstLaunch: true)
        vm.completeOnboarding()
        XCTAssertEqual(vm.currentScreen, .input)
    }

    func testMakePromise_transitionsToDisplay() {
        let vm = makeVM()
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        vm.makePromise(content: "毎朝7時に起きる", deadline: future)
        XCTAssertEqual(vm.currentScreen, .display)
        XCTAssertEqual(vm.currentPromise?.content, "毎朝7時に起きる")
    }

    func testAnswerYes_transitionsToAchievement() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        vm.answerKept(yes: true)
        XCTAssertEqual(vm.currentScreen, .achievement)
    }

    func testAnswerNo_transitionsToAcceptance() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        vm.answerKept(yes: false)
        XCTAssertEqual(vm.currentScreen, .acceptance)
    }

    func testCancelPromise_transitionsToInput() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: future))
        vm.cancelPromise()
        XCTAssertEqual(vm.currentScreen, .input)
        XCTAssertNil(vm.currentPromise)
    }

    func testProceedFromAchievement_transitionsToInput() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        vm.answerKept(yes: true)
        vm.proceedToNextPromise()
        XCTAssertEqual(vm.currentScreen, .input)
        XCTAssertNil(vm.currentPromise)
    }
}
