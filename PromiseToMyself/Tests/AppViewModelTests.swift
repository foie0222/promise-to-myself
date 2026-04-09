import Testing
import Foundation
@testable import PromiseToMyself

struct AppViewModelTests {
    @Test func initialState_firstLaunch_showsOnboarding() {
        let vm = AppViewModel(isFirstLaunch: true, savedPromise: nil)
        #expect(vm.currentScreen == .onboarding)
    }

    @Test func initialState_noPromise_showsInput() {
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: nil)
        #expect(vm.currentScreen == .input)
    }

    @Test func initialState_activePromise_showsDisplay() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        #expect(vm.currentScreen == .display)
    }

    @Test func initialState_expiredPromise_showsCheck() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        #expect(vm.currentScreen == .check)
    }

    @Test func completeOnboarding_transitionsToInput() {
        let vm = AppViewModel(isFirstLaunch: true, savedPromise: nil)
        vm.completeOnboarding()
        #expect(vm.currentScreen == .input)
    }

    @Test func makePromise_transitionsToDisplay() {
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: nil)
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        vm.makePromise(content: "毎朝7時に起きる", deadline: future)
        #expect(vm.currentScreen == .display)
        #expect(vm.currentPromise?.content == "毎朝7時に起きる")
    }

    @Test func answerYes_transitionsToAchievement() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.answerKept(yes: true)
        #expect(vm.currentScreen == .achievement)
    }

    @Test func answerNo_transitionsToAcceptance() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.answerKept(yes: false)
        #expect(vm.currentScreen == .acceptance)
    }

    @Test func cancelPromise_transitionsToInput() {
        let future = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let promise = Promise(content: "テスト", deadline: future)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.cancelPromise()
        #expect(vm.currentScreen == .input)
        #expect(vm.currentPromise == nil)
    }

    @Test func proceedFromAchievement_transitionsToInput() {
        let past = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let promise = Promise(content: "テスト", deadline: past)
        let vm = AppViewModel(isFirstLaunch: false, savedPromise: promise)
        vm.answerKept(yes: true)
        vm.proceedToNextPromise()
        #expect(vm.currentScreen == .input)
        #expect(vm.currentPromise == nil)
    }
}
