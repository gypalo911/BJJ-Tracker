//
//  JiuTrackWidget.swift
//  JiuTrackWidget
//
//  Created by Petro Hupalo on 25.02.2024.
//

import WidgetKit
import SwiftUI

struct SessionEntry: TimelineEntry {
    let date: Date
    
    var sessions: [Session] = []
    var techniques: [TechniqueModel] = []
    
    var todaySessions: [Session] {
        sessions.filter { $0.startDate?.isSame(as: Date(), by: [.day, .month, .year]) ?? false }
    }
    
    init(
        date: Date,
        sessions: [Session] = [],
        techniques: [TechniqueModel] = []
    ) {
        self.date = date
        self.sessions = sessions.count > 0 ? sessions : PersistanceManager.shared.fetchSessions()
        self.techniques = techniques.count > 0 ? techniques : PersistanceManager.shared.fetchAllTechniques()
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SessionEntry {
        return SessionEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SessionEntry) -> Void) {
        completion(SessionEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SessionEntry>) -> Void) {
        var entries: [SessionEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let entry = SessionEntry(date: entryDate)
            entries.append(entry)
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct JiuTrackWidget: Widget {
    let kind: String = "JiuTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            JiuTrackWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct JiuTrackWidgetEntryView: View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch(family) {
        case .systemMedium:
            SessionsListWidget(sessions: entry.todaySessions)
        case .systemLarge:
            StatsWidgetView(sessions: entry.sessions, techniques: entry.techniques)
        default:
            SessionsListWidget(sessions: entry.todaySessions)
        }
    }
}

#Preview(as: .systemMedium) {
    JiuTrackWidget()
} timeline: {
    SessionEntry(date: .now)
}

#Preview(as: .systemLarge) {
    JiuTrackWidget()
} timeline: {
    SessionEntry(date: .now)
}
