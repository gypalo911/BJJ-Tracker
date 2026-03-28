//
//  SessionDetailsMockSessionsStorageManager.swift
//  bjjtrackerTests
//
//  Created by OpenAI on 27.03.2026.
//

import Foundation
import CoreData
@testable import bjjtracker

final class SessionDetailsMockSessionsStorageManager: SessionsStorageManager {
    struct DeletedRepeatableSessionsCall: Equatable {
        let repeatableId: String
        let type: DeleteSessionType
    }

    private(set) var deletedSessions: [Session] = []
    private(set) var deletedRepeatableSessionsCalls: [DeletedRepeatableSessionsCall] = []

    func createSession(from activity: Activity, repeatableSettings: (any RepeatableSessionSettingsProtocol)?) {}

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

    func delete(session: Session) {
        deletedSessions.append(session)
    }

    func deleteRepeatableSessions(with repeatableId: String, type: DeleteSessionType) {
        deletedRepeatableSessionsCalls.append(
            DeletedRepeatableSessionsCall(
                repeatableId: repeatableId,
                type: type
            )
        )
    }
}
