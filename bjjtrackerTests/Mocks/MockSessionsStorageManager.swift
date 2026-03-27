//
//  MockSessionsStorageManager.swift
//  bjjtrackerTests
//
//  Created by Petro Hupalo on 26.03.2026.
//

import Foundation
import CoreData

final class MockSessionsStorageManager: SessionsStorageManager {
    struct CreatedSession {
        let activity: Activity
        let hasRepeatableSettings: Bool
    }

    private(set) var createdSessions: [CreatedSession] = []

    func createSession(from activity: Activity, repeatableSettings: (any RepeatableSessionSettingsProtocol)?) {
        createdSessions.append(
            CreatedSession(
                activity: activity,
                hasRepeatableSettings: repeatableSettings != nil
            )
        )
    }

    func fetchSessions(in interval: DateInterval?) -> [Session] {
        []
    }

    func session(by id: String) -> Session? {
        nil
    }

    func sessions(with repeatableId: String) -> [Session] {
        []
    }

    func update(session: Session, activity: Activity) {}

    func delete(session: Session) {}

    func deleteRepeatableSessions(with repeatableId: String, type: DeleteSessionType) {}
}
