//
//  SessionDetailsViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 13.07.2023.
//

import Foundation
import LinkPresentation
import UniformTypeIdentifiers

protocol SessionDetailsViewAnalytics {
    func linkOpened(_ link: String)
}

class SessionDetailsViewModel: ObservableObject {
    
    @Published var session: Session
    @Published var notesLinks: [String] = []
    
    @Published var previewModels: [LinkPreviewModel] = []
    
    private let analyticsEngine: AnalyticsEngine
    
    var navTitle: String {
        "\(session.activityStyle.rawValue.localizedString) \(session.activityType.rawValue.localizedString)"
    }
    
    init(session: Session, analyticsEngine: AnalyticsEngine = FirebaseAnalyticsEngine()) {
        self.session = session
        self.analyticsEngine = analyticsEngine
    }
    
    func setupLinkPreviews() {
        guard let notes = session.notes else {
            return
        }
        notesLinks = checkForUrls(text: notes)
//        Task {
//            await fetchMetadata(for: notesLinks)
//        }
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
}

extension SessionDetailsViewModel {
    func linkOpened(_ link: String) {
        analyticsEngine.log(AnalyticsEvent(name: "opened_link_from_session_details", metadata: ["link": link]))
    }
}

extension SessionDetailsViewModel {
    func fetchMetadata(for urlStrings: [String]) async {
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
    
    func append(model: LinkPreviewModel?) async {
        if let model = model {
            await MainActor.run {
                self.previewModels.append(model)
            }
        }
    }
    
    private func fetchMetadata(for previewURLString: String) async throws -> LinkPreviewModel? {
        guard let previewURL = URL(string: previewURLString) else { return nil }
        let provider = LPMetadataProvider()
        var linkPreviewModel = LinkPreviewModel(previewURL: previewURL)
        
        let metadata = try await provider.startFetchingMetadata(for: previewURL)
        let convertedImage = try await convertToImage(metadata.imageProvider)
        
        linkPreviewModel.image = convertedImage
        linkPreviewModel.title = metadata.title
        linkPreviewModel.url = metadata.url?.host
        
        return linkPreviewModel
    }
    
    private func convertToImage(_ imageProvider: NSItemProvider?) async throws -> UIImage? {
        var image: UIImage?
        
        if let imageProvider {
            let type = String(describing: UTType.image)
            
            if imageProvider.hasItemConformingToTypeIdentifier(type) {
                let item = try await imageProvider.loadItem(forTypeIdentifier: type)
                
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
            }
        }
        
        return image
    }
}
