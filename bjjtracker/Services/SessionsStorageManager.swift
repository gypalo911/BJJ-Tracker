//
//  SessionsStorageManager.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 26.03.2026.
//

import Foundation

enum DeleteSessionType: Equatable {
    case current
    case all
    case future(after: Date?)
}

protocol SessionsStorageManager {
    func createSession(from activity: Activity, repeatableSettings: (any RepeatableSessionSettingsProtocol)?)
    func fetchSessions(in interval: DateInterval?) -> [Session]
    func session(by id: String) -> Session?
    func sessions(with repeatableId: String) -> [Session]
    func update(session: Session, activity: Activity)
    func delete(session: Session)
    func deleteRepeatableSessions(with repeatableId: String, type: DeleteSessionType)
}
