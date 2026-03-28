//
//  SessionDetailsViewModelTests.swift
//  bjjtrackerTests
//
//  Created by Petro Hupalo on 27.03.2026.
//

import CoreData
import Foundation
import Testing
@testable import bjjtracker

@Suite(.serialized)
@MainActor
struct SessionDetailsViewModelTests {
    // MARK: - Properties
    private let persistanceManager: MockSessionsStorageManager
    private let notificationManager: MockNotificationManager
    private let analyticsEngine: MockAnalyticsEngine

    // MARK: - Setup
    init() {
        persistanceManager = MockSessionsStorageManager()
        notificationManager = MockNotificationManager()
        analyticsEngine = MockAnalyticsEngine()
    }

    // MARK: - Tests
    @Test
    func initExtractsLinksFromSessionNotes() async {
        let session = makeSession(
            notes: "Review https://example.com and https://bjjfanatics.com/article"
        )

        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )
        
        await sut.setupLinkPreviews()

        #expect(
            sut.notesLinks
                == ["https://example.com", "https://bjjfanatics.com/article"]
        )
    }

    @Test
    func checkForUrlsReturnsAllDetectedLinks() {
        let session = makeSession(notes: nil)
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )

        let links = sut.checkForUrls(
            text: "One https://example.com two http://ibjjf.com/rules and plain text"
        )

        #expect(links == ["https://example.com", "http://ibjjf.com/rules"])
    }

    @Test
    func linkOpenedLogsAnalyticsEvent() {
        let session = makeSession(notes: nil)
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )

        sut.linkOpened("https://example.com")

        #expect(analyticsEngine.loggedEvent?.name == "opened_link_from_session_details")
        #expect(analyticsEngine.loggedEvent?.metadata["link"] == "https://example.com")
    }

    @Test
    func deleteSessionDeletesCurrentSessionWhenRequestedTypeIsCurrent() {
        let session = makeSession(notes: nil, repeatableId: "repeatable-1")
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )

        sut.deleteSession(type: .current)

        #expect(persistanceManager.deletedSessions.count == 1)
        #expect(persistanceManager.deletedSessions.first == session)
        #expect(persistanceManager.deletedRepeatableSessionsCalls.isEmpty)
        #expect(notificationManager.removedPendingNotificationRequestIDs == [String(describing: session.id)])
    }

    @Test
    func deleteSessionDeletesRepeatableSessionsWhenRepeatableAndTypeIsNotCurrent() {
        let session = makeSession(notes: nil, repeatableId: "repeatable-1")
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )

        sut.deleteSession(type: .all)

        #expect(persistanceManager.deletedSessions.isEmpty)
        #expect(
            persistanceManager.deletedRepeatableSessionsCalls
                == [.init(repeatableId: "repeatable-1", type: .all)]
        )
        #expect(notificationManager.removedPendingNotificationRequestIDs == [String(describing: session.id)])
    }

    @Test
    func deleteSessionDeletesCurrentSessionWhenRepeatableIdentifierIsMissing() {
        let session = makeSession(notes: nil, repeatableId: nil)
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )

        sut.deleteSession(type: .all)

        #expect(persistanceManager.deletedSessions.count == 1)
        #expect(persistanceManager.deletedSessions.first == session)
        #expect(persistanceManager.deletedRepeatableSessionsCalls.isEmpty)
        #expect(notificationManager.removedPendingNotificationRequestIDs == [String(describing: session.id)])
    }

    @Test
    func appendAddsPreviewModelWhenModelExists() async {
        let session = makeSession(notes: nil)
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )
        let previewModel = LinkPreviewModel(
            image: nil,
            title: "Example",
            url: "example.com",
            previewURL: URL(string: "https://example.com")!
        )

        await sut.append(model: previewModel)

        #expect(sut.previewModels == [previewModel])
    }

    @Test
    func appendIgnoresNilPreviewModel() async {
        let session = makeSession(notes: nil)
        let sut = SessionDetailsViewModel(
            session: session,
            persistanceManager: persistanceManager,
            notificationManager: notificationManager,
            analyticsEngine: analyticsEngine
        )
        let model: LinkPreviewModel? = nil

        await sut.append(model: model)

        #expect(sut.previewModels.isEmpty)
    }

    // MARK: - Helpers
    private func makeSession(notes: String?, repeatableId: String? = nil) -> Session {
        let entity = makeSessionEntity()
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let session = Session(entity: entity, insertInto: context)
        session.id = UUID(uuidString: "12345678-1234-1234-1234-1234567890AB")
        session.repeatableId = repeatableId
        session.type = ActivityType.training.rawValue
        session.style = GraplingStyle.gi.rawValue
        session.duration = 60
        session.startDate = makeDate(year: 2026, month: 1, day: 5, hour: 18)
        session.location = "Academy"
        session.notes = notes

        return session
    }

    private func makeSessionEntity() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "Session"
        entity.managedObjectClassName = NSStringFromClass(Session.self)
        entity.properties = [
            makeAttribute(name: "id", type: .UUIDAttributeType),
            makeAttribute(name: "repeatableId", type: .stringAttributeType),
            makeAttribute(name: "type", type: .stringAttributeType),
            makeAttribute(name: "style", type: .stringAttributeType),
            makeAttribute(name: "duration", type: .integer16AttributeType),
            makeAttribute(name: "startDate", type: .dateAttributeType),
            makeAttribute(name: "location", type: .stringAttributeType),
            makeAttribute(name: "notes", type: .stringAttributeType)
        ]
        return entity
    }

    private func makeAttribute(name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        return attribute
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0

        return components.date ?? Date()
    }
}
