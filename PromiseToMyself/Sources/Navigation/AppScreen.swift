import SwiftUI

enum AppScreen: Equatable {
    case onboarding
    case input
    case display
    case check
    case achievement
    case acceptance
}

@Observable
final class AppViewModel {
    private(set) var currentScreen: AppScreen
    private(set) var currentPromise: Promise?

    @ObservationIgnored
    private let userDefaults: UserDefaults

    init(
        isFirstLaunch: Bool = !UserDefaults.standard.bool(forKey: "hasLaunched"),
        savedPromise: Promise? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults

        let promise: Promise?
        if let savedPromise {
            promise = savedPromise
        } else if let data = userDefaults.data(forKey: "currentPromise") {
            promise = try? JSONDecoder().decode(Promise.self, from: data)
        } else {
            promise = nil
        }
        self.currentPromise = promise

        if isFirstLaunch {
            self.currentScreen = .onboarding
        } else if let promise {
            self.currentScreen = promise.isExpired ? .check : .display
        } else {
            self.currentScreen = .input
        }
    }

    func completeOnboarding() {
        userDefaults.set(true, forKey: "hasLaunched")
        currentScreen = .input
    }

    func makePromise(content: String, deadline: Date) {
        let promise = Promise(content: content, deadline: deadline)
        currentPromise = promise
        savePromise(promise)
        NotificationService.scheduleDeadlineNotification(for: deadline)
        currentScreen = .display
    }

    func answerKept(yes: Bool) {
        currentScreen = yes ? .achievement : .acceptance
    }

    func cancelPromise() {
        currentPromise = nil
        clearPromise()
        NotificationService.cancelScheduledNotification()
        currentScreen = .input
    }

    func proceedToNextPromise() {
        currentPromise = nil
        clearPromise()
        NotificationService.cancelScheduledNotification()
        currentScreen = .input
    }

    private func savePromise(_ promise: Promise) {
        if let data = try? JSONEncoder().encode(promise) {
            userDefaults.set(data, forKey: "currentPromise")
        }
    }

    private func clearPromise() {
        userDefaults.removeObject(forKey: "currentPromise")
    }
}
