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
    @Environment (\.managedObjectContext) var managedObjContext
    
    @State private var isPresentedEditing: Bool = false
    @State private var urlToPresent: String?
    
    var dismissCallback: (() -> Void)? = nil
    
    var activityType: ActivityType {
        viewModel.session.activityType
    }
    
    var body: some View {
        ZStack {
            VStack {
                SessionDetailsHeaderView(
                    session: viewModel.session,
                    namespace: namespace,
                    navTitle: viewModel.navTitle,
                    isPresentedEditing: $isPresentedEditing,
                    dismissCallback: dismissCallback
                )
                .modifier(SwipeToDismissModifier(onDismiss: {
                    dismissCallback?()
                }))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        TechniquesListView(
                            viewModel: .init(
                                session: viewModel.session,
                                persistanceManager: persistanceManager
                            )
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(Color.black)
                            if let notes = viewModel.session.notes, !notes.isEmpty {
                                Text(LocalizedStringKey(notes))
                                    .font(.system(size: 18))
                                    .textSelection(.enabled)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text(LocalizedStringKey("Empty"))
                                    .foregroundColor(Color("LightGray"))
                                    .font(.system(size: 18))
                                    .textSelection(.enabled)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding(.horizontal, 10)
                        
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
                    .hAlign(.leading)
                    .vAlign(.top)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
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
                changeNavBar(UIColor(activityType.color.opacity(0.8)))
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
        }
        .introspectTabBarController { (UITabBarController) in
            UITabBarController.tabBar.isHidden = true
        }
        .onAppear {
            setupView()
        }
        .onChange(of: viewModel.session.notes) { _ in
            viewModel.setupLinkPreviews()
        }
    }
    
    func setupView() {
        changeNavBar(UIColor(activityType.color.opacity(0.8)))
        hideTabbar(true)
        viewModel.setupLinkPreviews()
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
    var dismissCallback: (() -> Void)? = nil
    
    var sessionId: String {
        session.id?.uuidString ?? ""
    }
    
    var activityType: ActivityType {
        session.activityType
    }
    var sessionStatus: ActivityStatus {
        session.status
    }
    
    var linearGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: activityType.color.opacity(0.8), location: 0.4),
                .init(color: activityType.color.opacity(0.35), location: 0.8),
                .init(color: activityType.color.opacity(0.28), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(linearGradient)
                .cornerRadius(30, corners: [.bottomLeft])
                .matchedGeometryEffect(id: "shape\(sessionId)", in: namespace)
                .defaultShadow()
                .vAlign(.top)
                .frame(width: UIScreen.main.bounds.size.width)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        dismissCallback?()
                    } label: {
                        Image("close")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        isPresentedEditing = true
                        changeNavBar(.clear)
                    } label: {
                        Text("Edit")
                            .fixedSize()
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 25)
                VStack {
                    HStack {
                        Text(navTitle)
                            .font(.system(size: 28).bold())
                            .foregroundColor(.white)
                            .hAlign(.leading)
                        ZStack {
                            Rectangle()
                                .foregroundColor(sessionStatus.color)
                                .cornerRadius(5)
                                .defaultShadow()
                                .frame(width: 76, height: 23)
                            Text("\(sessionStatus.rawValue.localizedString)".uppercased())
                                .font(.system(size: 10))
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
                                .font(.system(size: 20))
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
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                let duration = Int(session.duration)
                                if session.duration != 0 {
                                    Text(duration.minutesToDuration())
                                        .font(.system(size: 18))
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
                                    .font(.system(size: 20))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            } else {
                                Text(LocalizedStringKey("Empty"))
                                    .foregroundColor(Color("LightGray"))
                                    .fontWeight(.semibold)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .hAlign(.leading)
                }
                .padding(.horizontal, 15)
            }
            .vAlign(.top)
            .padding(.bottom, 30)
            .padding(.horizontal, 15)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: Preview
struct SessionDetailsView_Previews: PreviewProvider {
    struct Container: View {
        @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
        
        @Namespace var namespace
        
        var body: some View {
            let session: Session = sessionsList.map { $0 }.first!
            SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session))
        }
    }
    
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
