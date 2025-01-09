//
//  SessionDetailsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI
import Combine
import LinkPresentation
import Introspect

// MARK: SessionDetailsView
struct SessionDetailsView: View {
    
    let namespace: Namespace.ID
    
    @StateObject var viewModel: SessionDetailsViewModel
    
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var persistanceManager: PersistanceManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isPresentedEditing: Bool = false
    @State private var showShareSheet: Bool = false
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
                    dismissCallback: dismissCallback,
                    onDelete: {
                        viewModel.deleteSession()
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
                            Text("Notes")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.black)
                            if let notes = viewModel.session.notes, !notes.isEmpty {
                                Text(LocalizedStringKey(notes))
                                    .font(.body)
                                    .textSelection(.enabled)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text(LocalizedStringKey("Empty"))
                                    .foregroundColor(Color("DefaultLightGray"))
                                    .font(.body)
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
                    activity: ActivityModel.from(session: viewModel.session)!,
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
        }
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
        .navigationBarHidden(true)
        .onAppear {
            setupView()
        }
        .onChange(of: viewModel.session.notes) { _ in
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
}

// MARK: SessionDetailsHeaderView
struct SessionDetailsHeaderView: View {
    let session: Session
    
    let namespace: Namespace.ID
    let navTitle: String
    
    @Binding var isPresentedEditing: Bool
    @Binding var showShareSheet: Bool
    
    var dismissCallback: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
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
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                        Button(action: {
                            isPresentedEditing = true
                            changeNavBar(.clear)
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Divider()
                        Button(role: .destructive, action: {
                            onDelete?()
                        }) {
                            Label("Delete", systemImage: "trash")
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
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .hAlign(.leading)
                        ZStack {
                            Rectangle()
                                .foregroundColor(sessionStatus.color)
                                .cornerRadius(5)
                                .defaultShadow()
                                .frame(width: 76, height: 23)
                            Text("\(sessionStatus.rawValue.localizedString)".uppercased())
                                .font(.caption2)
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
                            Text("\((session.startDate ?? Date()).toString("dd MMMM yyyy"))")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        HStack(spacing: 10) {
                            Image("watch")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            HStack {
                                Text("\((session.startDate ?? Date()).toString("HH:mm"))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                let duration = Int(session.duration)
                                if session.duration != 0 {
                                    Text(duration.minutesToDuration())
                                        .font(.body)
                                        .fontWeight(.semibold)
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
                                Text("\(location)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            } else {
                                Text(LocalizedStringKey("Empty"))
                                    .foregroundColor(Color("DefaultLightGray"))
                                    .fontWeight(.semibold)
                                    .font(.title3)
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
