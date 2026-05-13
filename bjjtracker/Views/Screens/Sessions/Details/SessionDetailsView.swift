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
    
    typealias Localisation = SessionDetailsViewModel.Localisation
    
    @Environment(\.presentationMode) var presentationMode
    
    let namespace: Namespace.ID
    
    @StateObject var viewModel: SessionDetailsViewModel
    
    private let screenSize: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        ZStack {
            VStack {
                SessionDetailsHeaderView(
                    viewModel: viewModel,
                    namespace: namespace
                )
                .modifier(SwipeToDismissModifier(onDismiss: {
                    viewModel.dismissCallback?()
                }))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        TechniquesListView(viewModel: viewModel.makeTechniquesListViewModel())
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
            .sheet(isPresented: $viewModel.isPresentedEditing, onDismiss: {
                changeNavBar(UIColor(viewModel.activityType.color.opacity(0.8)))
            }) {
                EditSessionView(
                    viewModel: .init(),
                    session: viewModel.session,
                    activity: Activity.from(session: viewModel.session)!,
                    onDismiss: { editedActivity in
                        viewModel.dismissCallback?()
                    }
                )
            }
            .fullScreenCover(isPresented: $viewModel.showShareSheet) {
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
            .confirmationDialog(
                Localisation.deleteSessionsTitle,
                isPresented: $viewModel.showDeleteItemsDialog.animation(.easeInOut)
            ) {
                Button(Localisation.deleteOnlyThisSession, role: .destructive) {
                    viewModel.onSessionDelete(.current)
                }
                Button(Localisation.deleteAllSessions, role: .destructive) {
                    viewModel.onSessionDelete(.all)
                }
                Button(Localisation.deleteAllFutureSessions, role: .destructive) {
                    viewModel.onSessionDelete(.future(after: viewModel.session.startDate))
                }
                Button(Localisation.cancel, role: .cancel) { }
            } message: {
                Text(Localisation.deleteSessionsTitle)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupView()
        }
        .task {
            await viewModel.setupLinkPreviews()
        }
        .onChange(of: viewModel.session.notes) {
            Task {
                await viewModel.setupLinkPreviews()
            }
        }
    }
    
    func setupView() {
        changeNavBar(UIColor(viewModel.activityType.color.opacity(0.8)))
        viewModel.hideTabbar(true)
    }
}

// MARK: SessionDetailsHeaderView
struct SessionDetailsHeaderView: View {
    
    typealias Localisation = SessionDetailsViewModel.Localisation
    
    @StateObject var viewModel: SessionDetailsViewModel
    
    let namespace: Namespace.ID
    
    var activityColor: Color {
        viewModel.session.activityType.color
    }
    
    var sessionId: String {
        viewModel.session.id?.uuidString ?? ""
    }
    
    var session: SessionEntity {
        viewModel.session
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
                        viewModel.dismissCallback?()
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
                                viewModel.showShareSheet = true
                            }) {
                                Label {
                                    Text(Localisation.share)
                                } icon: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                        }
                        Button(action: {
                            viewModel.isPresentedEditing = true
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
                                viewModel.showDeleteItemsDialog = true
                            } else {
                                viewModel.onSessionDelete(.current)
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
                        Text(viewModel.navTitle)
                            .font(token: DesignSystem.shared.fonts.title)
                            .foregroundColor(.white)
                            .hAlign(.leading)
                        ZStack {
                            Rectangle()
                                .foregroundColor(viewModel.session.status.color)
                                .cornerRadius(5)
                                .defaultShadow()
                                .frame(width: 86, height: 23)
                            Text(viewModel.session.status.rawValue.localizedString.uppercased())
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
        //        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<SessionEntity>
        @EnvironmentObject var persistanceManager: PersistanceManager
        
        @Namespace var namespace
        
        var body: some View {
            let session: SessionEntity = persistanceManager.fetchSessions().first!
            SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session, persistanceManager: PersistanceManager.preview, notificationManager: NotificationManager()))
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environmentObject(PersistanceManager.preview)
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
