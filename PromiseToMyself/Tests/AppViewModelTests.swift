import Testing
import Foundation
@testable import PromiseToMyself

struct AppViewModelTests {
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

    @Test func initialState_firstLaunch_showsOnboarding() {
        let vm = makeVM(isFirstLaunch: true)
        #expect(vm.currentScreen == .onboarding)
    }

    @Test func initialState_noPromise_showsInput() {
        let vm = makeVM()
        #expect(vm.currentScreen == .input)
    }

    @Test func initialState_activePromise_showsDisplay() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: future))
        #expect(vm.currentScreen == .display)
    }

    @Test func initialState_expiredPromise_showsCheck() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        #expect(vm.currentScreen == .check)
    }

    @Test func completeOnboarding_transitionsToInput() {
        let vm = makeVM(isFirstLaunch: true)
        vm.completeOnboarding()
        #expect(vm.currentScreen == .input)
    }

    @Test func makePromise_transitionsToDisplay() {
        let vm = makeVM()
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        vm.makePromise(content: "毎朝7時に起きる", deadline: future)
        #expect(vm.currentScreen == .display)
        #expect(vm.currentPromise?.content == "毎朝7時に起きる")
    }

    @Test func answerYes_transitionsToAchievement() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        vm.answerKept(yes: true)
        #expect(vm.currentScreen == .achievement)
    }

    @Test func answerNo_transitionsToAcceptance() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        vm.answerKept(yes: false)
        #expect(vm.currentScreen == .acceptance)
    }

    @Test func cancelPromise_transitionsToInput() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: future))
        vm.cancelPromise()
        #expect(vm.currentScreen == .input)
        #expect(vm.currentPromise == nil)
    }

    @Test func proceedFromAchievement_transitionsToInput() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let vm = makeVM(savedPromise: Promise(content: "テスト", deadline: past))
        vm.answerKept(yes: true)
        vm.proceedToNextPromise()
        #expect(vm.currentScreen == .input)
        #expect(vm.currentPromise == nil)
    }
}
