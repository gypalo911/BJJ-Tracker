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
    
    @StateObject var viewModel: SessionDetailsViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isPresentedEditing: Bool = false
    
    var dismissCallback: (() -> Void)? = nil
    
    var activityType: ActivityType {
        viewModel.session.activityType
    }
    
    var sessionStatus: ActivityStatus {
        viewModel.session.status
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
                                }.padding(.all, 30)
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            VStack(alignment: .leading, spacing: 20) {
                                Text(viewModel.navTitle)
                                    .font(.system(size: 28).bold())
                                    .foregroundColor(.white)
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
                                    TechniquesListView()
                                }
                                .padding(.top, 20)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Notes")
                                        .font(.system(size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.black)
                                    Text(LocalizedStringKey(viewModel.session.notes ?? "Empty"))
                                        .font(.system(size: 18))
                                        .textSelection(.enabled)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, 10)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                    ForEach(viewModel.notesLinks, id: \.self) { urlString in
                                        LinkPreview(viewModel: .init(urlString))
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
                            Rectangle()
                                .fill(linearGradient)
                                .ignoresSafeArea()
                                .cornerRadius(30, corners: [.bottomLeft])
                                .frame(height: 480)
                                .position(CGPoint(x: geometry.size.width/2, y: 0))
                                .defaultShadow()
                        }
                        .sheet(isPresented: $isPresentedEditing, onDismiss: {
                            let appearance = UINavigationBarAppearance()
                            appearance.backgroundColor = UIColor(activityType.color.opacity(0.8))
                            UINavigationBar.appearance().standardAppearance = appearance
                        }) {
                            EditSessionView(
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
        
        var body: some View {
            let session: Session = sessionsList.map { $0 }.first!
            SessionDetailsView(viewModel: SessionDetailsViewModel(session: session))
        }
    }
    
    static var previews: some View {
        Container()
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
