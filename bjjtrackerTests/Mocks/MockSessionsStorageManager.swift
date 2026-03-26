//
//  MockSessionsStorageManager.swift
//  bjjtrackerTests
//
//  Created by Petro Hupalo on 26.03.2026.
//

import Foundation
import CoreData

//class MockSessionsStorageManager: SessionsStorageManager {
//    
//    var sessions: [Session] = []
//    var container: NSPersistentCloudKitContainer = NSPersistentCloudKitContainer(name: "testbjjtracker")
//
//    func createSession(from activity: Activity, repeatableSettings: RepeatableSessionSettings?) {
//        let context = self.container.viewContext
//        let session = Session(context: context)
//        session.update(with: activity)
//        
//        sessions.append(session)
//    }
//    
//    func fetchSessions(in interval: DateInterval?) -> [Session] {
//        []
//    }
//    
//    func session(by id: String) -> Session? {
//        nil
//    }
//    
//    func sessions(with repeatableId: String) -> [Session] {
//        []
//    }
//    
//    func update(session: Session, activity: Activity) {
//        
//    }
//    
//    func delete(session: Session) {
//        
//    }
//
//    func deleteRepeatableSessions(with repeatableId: String, type: DeleteSessionType) {
//        
//    }
//}
