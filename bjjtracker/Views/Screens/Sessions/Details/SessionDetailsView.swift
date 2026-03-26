//
//  SessionDetailsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI
import Combine
import LinkPresentation

// MARK: SessionDetailsView
struct SessionDetailsView: View {
    private enum Localisation {
        static var notes: String { "Notes".localizedString }
        static var empty: String { "Empty".localizedString }
        static var deleteSessionsTitle: String { "Delete sessions".localizedString }
        static var deleteOnlyThisSession: String { "Delete only this session".localizedString }
        static var deleteAllSessions: String { "Delete all sessions".localizedString }
        static var deleteAllFutureSessions: String { "Delete all future sessions".localizedString }
        static var cancel: String { "Cancel".localizedString }
    }
    
    let namespace: Namespace.ID
    
    @StateObject var viewModel: SessionDetailsViewModel
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isPresentedEditing: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showDeleteItemsDialog: Bool = false
    @State private var urlToPresent: String?
    
    var dismissCallback: (() -> Void)? = nil
    
    var activityType: ActivityType {
        viewModel.session.activityType
    }
    
    var activityColor: Color {
        activityType.color
    }
    
    private let screenSize: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack {
            VStack {
                SessionDetailsHeaderView(
                    session: viewModel.session,
                    namespace: namespace,
                    navTitle: viewModel.navTitle,
                    isPresentedEditing: $isPresentedEditing,
                    showShareSheet: $showShareSheet,
                    showDeleteItemsDialog: $showDeleteItemsDialog,
                    dismissCallback: dismissCallback,
                    onDelete: { type in
                        viewModel.deleteSession(type: type)
                        dismissCallback?()
                    }
                )
                .modifier(SwipeToDismissModifier(onDismiss: {
                    dismissCallback?()
                }))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        TechniquesListView(
                            updateTags: $viewModel.updateTags,
                            viewModel: .init(
                                session: viewModel.session,
                                persistanceManager: persistanceManager,
                                onTechniqueDetails: { technique in
                                    viewModel.isShowingTechniqueDetails = true
                                    viewModel.selectedTechnique = technique
                                }
                            )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(Localisation.notes)
                                .font(token: DesignSystem.shared.fonts.body, weight: .semibold)
                                .foregroundColor(Color.black)
                            if let notes = viewModel.session.notes, !notes.isEmpty {
                                Text(LocalizedStringKey(notes))
                                    .font(token: DesignSystem.shared.fonts.body)
                                    .textSelection(.enabled)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text(Localisation.empty)
                                    .foregroundColor(DesignSystem.shared.colors.lightGray)
                                    .font(token: DesignSystem.shared.fonts.body)
                                    .textSelection(.enabled)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        Group {
                            if !viewModel.notesLinks.isEmpty {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                    ForEach(viewModel.previewModels, id: \.self) { model in
                                        LinkPreview(
                                            previewModel: model, onTap: { link in
                                                viewModel.linkOpened(link)
                                            }
                                        )
                                    }
                                }
                                if viewModel.notesLinks.count > viewModel.previewModels.count {
                                    ProgressView()
                                        .hAlign(.center)
                                }
                            }
                        }
                    }
                    .padding(.bottom, screenSize.width <= 375 ? 30 : 10)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    .hAlign(.leading)
                    .vAlign(.top)
                }
            }
            .ignoresSafeArea(.keyboard)
            .onDisappear {
                changeNavBar(.clear)
            }
            .background {
                Rectangle()
                    .fill(.white)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $isPresentedEditing, onDismiss: {
                changeNavBar(UIColor(activityColor.opacity(0.8)))
            }) {
                EditSessionView(
                    viewModel: .init(),
                    session: viewModel.session,
                    activity: Activity.from(session: viewModel.session)!,
                    onDismiss: { editedActivity in
                        dismissCallback?()
                    }
                )
            }
            .fullScreenCover(isPresented: $showShareSheet) {
                if #available(iOS 16.0, *) {
                    ShareSessionView(session: viewModel.session)
                }
            }
            .bottomSheet(isPresented: $viewModel.isShowingTechniqueDetails) {
                if let technique = viewModel.selectedTechnique {
                    TechniqueModalView(
                        showingCreateTechnique: $viewModel.isShowingTechniqueDetails,
                        state: .overview,
                        technique: technique,
                        onUpdate: { value in
                            viewModel.updateTags.toggle()
                        }
                    )
                }
            }
            .confirmationDialog(Localisation.deleteSessionsTitle, isPresented: $showDeleteItemsDialog.animation(.easeInOut)) {
                Button(Localisation.deleteOnlyThisSession, role: .destructive) {
                    onSessionDelete(.current)
                }
                Button(Localisation.deleteAllSessions, role: .destructive) {
                    onSessionDelete(.all)
                }
                Button(Localisation.deleteAllFutureSessions, role: .destructive) {
                    onSessionDelete(.future(after: viewModel.session.startDate))
                }
                Button(Localisation.cancel, role: .cancel) { }
            } message: {
                Text(Localisation.deleteSessionsTitle)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true)
        .onAppear {
            setupView()
        }
        .onChange(of: viewModel.session.notes) {
            viewModel.setupLinkPreviews()
        }
    }
    
    func setupView() {
        changeNavBar(UIColor(activityColor.opacity(0.8)))
        hideTabbar(true)
    }
    
    func hideTabbar(_ isHidden: Bool) {
        settings.isTabBarHidden = isHidden
    }
    
    private func onSessionDelete(_ type: DeleteSessionType) {
        viewModel.deleteSession(type: type)
        dismissCallback?()
    }
}

// MARK: SessionDetailsHeaderView
struct SessionDetailsHeaderView: View {
    private enum Localisation {
        static var share: String { "Share".localizedString }
        static var edit: String { "Edit".localizedString }
        static var delete: String { "Delete".localizedString }
        static var empty: String { "Empty".localizedString }
        static var repeatableSession: String { "Repeatable session".localizedString }
    }

    let session: Session
    
    let namespace: Namespace.ID
    let navTitle: String
    
    @Binding var isPresentedEditing: Bool
    @Binding var showShareSheet: Bool
    @Binding var showDeleteItemsDialog: Bool
    
    var dismissCallback: (() -> Void)? = nil
    var onDelete: ((DeleteSessionType) -> Void)? = nil
    
    var sessionId: String {
        session.id?.uuidString ?? ""
    }
    
    var activityType: ActivityType {
        session.activityType
    }
    
    var activityColor: Color {
        activityType.color
    }
    
    var sessionStatus: ActivityStatus {
        session.status
    }
    
    var linearGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: activityColor.opacity(0.8), location: 0.4),
                .init(color: activityColor.opacity(0.35), location: 0.8),
                .init(color: activityColor.opacity(0.28), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private let screenSize: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(linearGradient)
                .cornerRadius(30, corners: [.bottomLeft])
                .defaultShadow()
                .vAlign(.top)
                .frame(width: screenSize.width)
                .ignoresSafeArea()
                .matchedGeometryEffect(id: "shape\(sessionId)", in: namespace)
            
            VStack {
                HStack(alignment: .bottom) {
                    Button {
                        dismissCallback?()
                    } label: {
                        Image("close")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Menu {
                        if #available(iOS 16.0, *) {
                            Button(action: {
                                showShareSheet = true
                            }) {
                                Label {
                                    Text(Localisation.share)
                                } icon: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                        Button(action: {
                            isPresentedEditing = true
                            changeNavBar(.clear)
                        }) {
                            Label {
                                Text(Localisation.edit)
                            } icon: {
                                Image(systemName: "pencil")
                            }
                        }
                        Divider()
                        Button(role: .destructive, action: {
                            if session.repeatableId != nil {
                                showDeleteItemsDialog = true
                            } else {
                                onDelete?(.current)
                            }
                        }) {
                            Label {
                                Text(Localisation.delete)
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 30)
                .padding(.bottom, 10)
                VStack {
                    HStack {
                        Text(navTitle)
                            .font(token: DesignSystem.shared.fonts.title)
                            .foregroundColor(.white)
                            .hAlign(.leading)
                        ZStack {
                            Rectangle()
                                .foregroundColor(sessionStatus.color)
                                .cornerRadius(5)
                                .defaultShadow()
                                .frame(width: 86, height: 23)
                            Text(sessionStatus.rawValue.localizedString.uppercased())
                                .font(token: DesignSystem.shared.fonts.caption2)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .padding(.trailing, -15)
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 10) {
                            Image("calendar")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Text(verbatim: (session.startDate ?? Date()).toString("dd MMMM yyyy"))
                                .font(token: DesignSystem.shared.fonts.title3, weight: .semibold)
                                .foregroundColor(.white)
                        }
                        HStack(spacing: 10) {
                            Image("watch")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            HStack {
                                Text(verbatim: (session.startDate ?? Date()).toString("HH:mm"))
                                    .font(token: DesignSystem.shared.fonts.title3, weight: .semibold)
                                    .foregroundColor(.white)
                                let duration = Int(session.duration)
                                if session.duration != 0 {
                                    Text(duration.minutesToDuration())
                                        .font(token: DesignSystem.shared.fonts.body, weight: .semibold)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        HStack(spacing: 10) {
                            Image("location")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            
                            if let location = session.location, !location.isEmpty {
                                Text(verbatim: location)
                                    .font(token: DesignSystem.shared.fonts.title3, weight: .semibold)
                                    .foregroundColor(.white)
                            } else {
                                Text(Localisation.empty)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .font(token: DesignSystem.shared.fonts.title3)
                            }
                        }
                        
                        if session.repeatableId != nil {
                            HStack(spacing: 10) {
                                Image(systemName: "repeat.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                Text(Localisation.repeatableSession)
                                    .font(token: DesignSystem.shared.fonts.body, weight: .semibold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                    .hAlign(.leading)
                }
                .padding(.horizontal, 15)
            }
            .vAlign(.top)
            .padding(.top, 30)
            .padding(.bottom, 30)
            .padding(.horizontal, 15)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: Preview
struct SessionDetailsView_Previews: PreviewProvider {
    struct Container: View {
        //        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
        @EnvironmentObject var persistanceManager: PersistanceManager
        
        @Namespace var namespace
        
        var body: some View {
            let session: Session = persistanceManager.fetchSessions().first!
            SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session, persistanceManager: PersistanceManager.preview))
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environmentObject(PersistanceManager.preview)
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
