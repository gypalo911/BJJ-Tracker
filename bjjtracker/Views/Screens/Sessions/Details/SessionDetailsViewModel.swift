//
//  SessionDetailsViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import Foundation
import LinkPresentation
import UniformTypeIdentifiers
import Combine

protocol SessionDetailsViewAnalytics {
    func linkOpened(_ link: String)
}

class SessionDetailsViewModel: ObservableObject {
    
    // MARK: Typealias
    
    typealias StorageManager = SessionsStorageManager & TechniquesStorageManager
    
    // MARK: Private variables
    
    private let persistanceManager: StorageManager
    private let notificationManager: NotificationManagerProtocol
    private let appSettings: AppSettings
    private let analyticsEngine: AnalyticsEngine
    private let loadsLinkPreviews: Bool
    
    // MARK: Public variables
    
    @Published var session: SessionEntity
    @Published var notesLinks: [String] = []
    @Published var previewModels: [LinkPreviewModel] = []
    
    @Published var isShowingTechniqueDetails: Bool = false
    @Published var selectedTechnique: TechniqueModel?
    
    @Published var updateTags: Bool = false
    
    @Published var isPresentedEditing: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var showDeleteItemsDialog: Bool = false
    
    var dismissCallback: (() -> Void)?
    
    var activityType: ActivityType {
        session.activityType
    }
    
    var navTitle: String {
        "\(session.activityType.rawValue.localizedString) \(session.activityStyle.rawValue.localizedString)"
    }
    
    // MARK: Init
    
    init(
        session: SessionEntity,
        appSettings: AppSettings = .shared,
        persistanceManager: StorageManager,
        notificationManager: NotificationManagerProtocol,
        analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine(),
        loadsLinkPreviews: Bool = true,
        dismissCallback: (() -> Void)? = nil
    ) {
        self.session = session
        self.appSettings = appSettings
        self.persistanceManager = persistanceManager
        self.notificationManager = notificationManager
        self.analyticsEngine = analyticsEngine
        self.loadsLinkPreviews = loadsLinkPreviews
        self.dismissCallback = dismissCallback
    }
    
    // MARK: Public methods
    
    @MainActor
    func setupLinkPreviews() async {
        guard let notes = session.notes else {
            return
        }
        notesLinks = checkForUrls(text: notes)
        guard loadsLinkPreviews else {
            return
        }
        await fetchMetadata(for: notesLinks)
    }
    
    func checkForUrls(text: String) -> [String] {
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            
            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
            
            return matches.compactMap({ $0.url?.absoluteString })
        } catch {}
        
        return []
    }
    
    func onSessionDelete(_ type: DeleteSessionType) {
        deleteSession(type: type)
        dismissCallback?()
    }
    
    func deleteSession(type: DeleteSessionType) {
        if let repeatableId = session.repeatableId, type != .current {
            persistanceManager.deleteRepeatableSessions(with: repeatableId, type: type)
        } else {
            persistanceManager.delete(session: session)
        }
        notificationManager.removePendingNotificationRequests(with: [String(describing: session.id)])
    }
    
    func hideTabbar(_ isHidden: Bool) {
        appSettings.isTabBarHidden = isHidden
    }
    
    func makeTechniquesListViewModel() -> TechniquesListViewModel {
        TechniquesListViewModel(
            session: session,
            persistanceManager: persistanceManager,
            updateTags: updateTags,
            onTechniqueDetails: { [weak self] technique in
                guard let self else { return }
                
                isShowingTechniqueDetails = true
                selectedTechnique = technique
            }
        )
    }
}

extension SessionDetailsViewModel: SessionDetailsViewAnalytics {
    func linkOpened(_ link: String) {
        analyticsEngine.log(AnalyticsEvent(
            name: "opened_link_from_session_details",
            metadata: ["link": link]
        ))
    }
}

private extension SessionDetailsViewModel {

    func fetchMetadata(for urlStrings: [String]) async {
        guard !urlStrings.isEmpty else { return }
        for link in notesLinks {
            var metadata: LinkPreviewModel?
            do {
                if let result = try await fetchMetadata(for: link) {
                    metadata = result
                }
            } catch {}
            
            await self.append(model: metadata)
        }
    }
    
    @MainActor
    func append(model: LinkPreviewModel?) async {
        guard let model else {
            return
        }
        self.previewModels.append(model)
    }
    
    @MainActor
    func fetchMetadata(for previewURLString: String) async throws -> LinkPreviewModel? {
        guard let previewURL = URL(string: previewURLString) else { return nil }
        let provider = LPMetadataProvider()
        var linkPreviewModel = LinkPreviewModel(previewURL: previewURL)
        
        let metadata = try await provider.startFetchingMetadata(for: previewURL)
        if let image = try await loadImage(from: metadata) {
            linkPreviewModel.image = image
        }
        
        linkPreviewModel.title = metadata.title
        linkPreviewModel.url = metadata.url?.host
        
        return linkPreviewModel
    }
    
    func loadImage(from metadata: LPLinkMetadata) async throws -> UIImage? {
        guard let imageProvider = metadata.imageProvider else {
            return nil
        }
        let type = String(describing: UTType.image)
        let item = try await imageProvider.loadItem(forTypeIdentifier: type)
        let convertedImage = try await convertToImage(item)
        return convertedImage
    }
    
    func convertToImage(_ item: NSSecureCoding) async throws -> UIImage? {
        var image: UIImage?
        
        if item is UIImage {
            image = item as? UIImage
        }
        
        if item is URL {
            guard let url = item as? URL,
                  let data = try? Data(contentsOf: url)
            else {
                return nil
            }
            
            image = UIImage(data: data)
        }
        
        if item is Data {
            guard let data = item as? Data else { return nil }
            
            image = UIImage(data: data)
        }
        
        return image
    }
}


extension SessionDetailsViewModel {
    enum Localisation {
        static var notes: String { "Notes".localizedString }
        static var empty: String { "Empty".localizedString }
        static var deleteSessionsTitle: String { "Delete sessions".localizedString }
        static var deleteOnlyThisSession: String { "Delete only this session".localizedString }
        static var deleteAllSessions: String { "Delete all sessions".localizedString }
        static var deleteAllFutureSessions: String { "Delete all future sessions".localizedString }
        static var cancel: String { "Cancel".localizedString }
        static var share: String { "Share".localizedString }
        static var edit: String { "Edit".localizedString }
        static var delete: String { "Delete".localizedString }
        static var repeatableSession: String { "Repeatable session".localizedString }
    }
}
