//
//  SessionDetailsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 10.04.2023.
//

import SwiftUI
import Combine
import LinkPresentation

struct SessionDetailsView: View {
    
    let namespace: Namespace.ID
    
    @StateObject var viewModel: SessionDetailsViewModel
    
    @Environment(\.presentationMode) var presentationMode
    @Environment (\.managedObjectContext) var managedObjContext
    
    @State private var isPresentedEditing: Bool = false
    @State private var urlToPresent: String?
    
    var dismissCallback: (() -> Void)? = nil
    
    var activityType: ActivityType {
        viewModel.session.activityType
    }
    
    var sessionStatus: ActivityStatus {
        viewModel.session.status
    }
    
    var sessionId: String {
        viewModel.session.id?.uuidString ?? ""
    }
    
    var body: some View {
        
        let linearGradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: activityType.color.opacity(0.8), location: 0.4),
                .init(color: activityType.color.opacity(0.35), location: 0.8),
                .init(color: activityType.color.opacity(0.28), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        NavigationView {
            GeometryReader { geometry in
                ScrollViewReader { reader in
                    ScrollView {
                        ZStack {
                            Group {
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
                                .matchedGeometryEffect(id: "status\(sessionId)", in: namespace)
                                .padding(.all, 30)
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            VStack(alignment: .leading, spacing: 20) {
                                Text(viewModel.navTitle)
                                    .font(.system(size: 28).bold())
                                    .foregroundColor(.white)
                                    .matchedGeometryEffect(id: "title\(sessionId)", in: namespace, properties: .position, anchor: .center)
                                    .padding(.top, 10)
                                VStack(alignment: .leading, spacing: 20) {
                                    HStack(spacing: 10) {
                                        Image("calendar")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.white)
                                        Text("\((viewModel.session.startDate ?? Date()).toString("dd MMMM yyyy"))")
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
                                            Text("\((viewModel.session.startDate ?? Date()).toString("HH:mm"))")
                                                .font(.system(size: 20))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            let duration = Int(viewModel.session.duration)
                                            if viewModel.session.duration != 0 {
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
                                        Text("\(viewModel.session.location ?? "--")")
                                            .font(.system(size: 20))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                }.padding(10)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    TechniquesListView(
                                        viewModel: .init(session: viewModel.session, managedObjContext: managedObjContext)
                                    )
                                }
                                .padding(.top, 20)
                                
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
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                    ForEach(viewModel.notesLinks, id: \.self) { urlString in
                                        LinkPreview(
                                            viewModel: .init(urlString),
                                            onTap: { link in
                                                viewModel.linkOpened(link)
                                            }
                                        )
                                    }
                                }
                            }
                            .hAlign(.leading)
                            .vAlign(.top)
                            .padding(20)
                            .ignoresSafeArea(.keyboard)
                            .onDisappear {
                                let appearance = UINavigationBarAppearance()
                                appearance.backgroundColor = .clear
                                UINavigationBar.appearance().standardAppearance = appearance
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        dismissCallback?()
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        Image("back")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(.white)
                                    }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        isPresentedEditing = true
                                        let appearance = UINavigationBarAppearance()
                                        appearance.backgroundColor = .clear
                                        UINavigationBar.appearance().standardAppearance = appearance
                                    } label: {
                                        Text("Edit")
                                            .fixedSize()
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .background {
                            ZStack {
                                Rectangle()
                                    .fill(.white)
                                    .ignoresSafeArea()
                                    .matchedGeometryEffect(id: "whiteBG\(sessionId)", in: namespace, properties: .position, anchor: .center)
                                Rectangle()
                                    .fill(linearGradient)
                                    .ignoresSafeArea()
                                    .cornerRadius(30, corners: [.bottomLeft])
                                    .matchedGeometryEffect(id: "shape\(sessionId)", in: namespace, properties: .position, anchor: .leading)
                                    .frame(height: 480)
                                    .position(CGPoint(x: geometry.size.width/2, y: 0))
                                    .defaultShadow()
                            }
                        }
                        .sheet(isPresented: $isPresentedEditing, onDismiss: {
                            let appearance = UINavigationBarAppearance()
                            appearance.backgroundColor = UIColor(activityType.color.opacity(0.8))
                            UINavigationBar.appearance().standardAppearance = appearance
                        }) {
                            EditSessionView(
                                viewModel: .init(),
                                session: viewModel.session,
                                activity: Activity.from(session: viewModel.session)!,
                                onDismiss: { editedActivity in
                                    presentationMode.wrappedValue.dismiss()
                                }
                            )
                        }
                    }
                }
                .onAppear {
                    setupView()
                }
            }
        }
    }
    
    func changeNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(activityType.color.opacity(0.8))
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    func setupView() {
        changeNavBar()
        viewModel.setupNavTitle()
        viewModel.setupLinkPreviews()
    }
}

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
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
