//
//  JournalViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 14.07.2023.
//

import Foundation

class JournalViewViewModel: ObservableObject {
    
    typealias StorageManager = SessionsStorageManager & PromotionsStorageManager
    
    // MARK: Variables
    private let persistanceManager: StorageManager
    private let analyticsEngine: AnalyticsEngine
    
    @Published var showingPromotionsView: Bool = false
    @Published var sessions: [Session] = []
    @Published var promotionModels: [PromotionModel] = []
    
    @Published var selectedSession: Session?
    @Published var selectedSheet: ModalSheets? = nil
    
    @Published var selectedGradingSystem: GradingSystem = .adult
    
    var groupedSessions: [String: [Session]] {
        Dictionary(grouping: sessions, by: { $0.startDateString })
    }
    
    var groupedPromotions: [String: [Promotion]] {
        let promotions = promotionModels.map { Promotion.from($0) }
        return Dictionary(grouping: promotions, by: { $0.date.startOfDayString })
    }
    
    var sections: [String] {
        Set(Array(groupedSessions.keys) + Array(groupedPromotions.keys))
            .map { String($0) }
            .sorted(by: {
                $0.toDate(format: "dd MMMM yyyy")! > $1.toDate(format: "dd MMMM yyyy")!
            })
    }
    
    init(
        persistanceManager: StorageManager,
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()
    ) {
        self.persistanceManager = persistanceManager
        self.analyticsEngine = analyticsEngine
        
        setup()
    }
    
    func onJournalViewAppeared() {
        analyticsEngine.log(AnalyticsEvent(name: "journal_screen_viewed", metadata: [:]))
    }
    
    func setup() {
        fetchSessions()
        fetchPromotions()
    }
    
    // MARK: Functions
    func fetchSessions(in interval: DateInterval? = nil) {
        let fetchedSessions = persistanceManager.fetchSessions(in: interval)
        sessions = fetchedSessions
    }
    
    // MARK: Functions
    func fetchPromotions(in interval: DateInterval? = nil) {
        let fetchedPromotions = persistanceManager.fetchPromotions(in: interval)
        promotionModels = fetchedPromotions
    }
}


// MARK: Analytics functions
extension JournalViewViewModel {
    func createSessionButtonTapped() {
        analyticsEngine.log(AnalyticsEvent(name: "create_session_button_tapped", metadata: [:]))
    }
    
    func addPromotionButtonTapped() {
        analyticsEngine.log(AnalyticsEvent(name: "add_promotion_button_tapped", metadata: [:]))
    }
}
