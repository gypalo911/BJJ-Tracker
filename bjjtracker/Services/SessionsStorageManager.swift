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
    func fetchSessions(in interval: DateInterval?) -> [SessionEntity]
    func session(by id: String) -> SessionEntity?
    func sessions(with repeatableId: String) -> [SessionEntity]
    func update(session: SessionEntity, activity: Activity)
    func delete(session: SessionEntity)
    func deleteRepeatableSessions(with repeatableId: String, type: DeleteSessionType)
}
