//
//  SessionDetailsViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import Foundation

protocol SessionDetailsViewAnalytics {
    func linkOpened(_ link: String)
}

class SessionDetailsViewModel: ObservableObject {
    
    @Published var session: Session
    @Published var navTitle: String = ""
    @Published var notesLinks: [String] = []
    
    private let analyticsEngine: AnalyticsEngine
    
    init(session: Session, analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.session = session
        self.analyticsEngine = analyticsEngine
    }
    
    func setupNavTitle() {
        self.navTitle = "\(session.activityStyle.rawValue.localizedString) \(session.activityType.rawValue.localizedString)"
    }
    
    func setupLinkPreviews() {
        if let notes = session.notes {
            notesLinks = checkForUrls(text: notes)
        }
    }
    
    func checkForUrls(text: String) -> [String] {
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            
            return matches.compactMap({ $0.url?.absoluteString })
        } catch let _ {
//            debugPrint(error.localizedDescription)
        }
        
        return []
    }
}

extension SessionDetailsViewModel {
    func linkOpened(_ link: String) {
        analyticsEngine.log(AnalyticsEvent(name: "opened_link_from_session_details", metadata: ["link": link]))
    }
}
