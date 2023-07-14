//
//  ArchiveView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI
import Introspect

struct ArchiveView: View {
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    
    @StateObject var viewModel: ArchiveViewViewModel
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @Environment (\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut)
    var sessions: FetchedResults<Session>
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut)
    var promotionModels: FetchedResults<PromotionModel>
    
    @State private var selectedSession: Session?
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets? = nil
    
    private var groupedSessions: [String: [Session]] {
        Dictionary(grouping: sessions, by: { $0.startDateString })
    }
    
    private var groupedPromotions: [String: [PromotionModel]] {
        Dictionary(grouping: promotionModels, by: { $0.dateString })
    }
    
    private var sections: [String] {
        Set(Array(groupedSessions.keys) + Array(groupedPromotions.keys))
            .map { String($0) }
            .sorted(by: {
                $0.toDate(format: "dd MMMM yyyy")! > $1.toDate(format: "dd MMMM yyyy")!
            })
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                ScrollView {
                    if !sections.isEmpty {
                        VStack {
                            ForEach(sections, id: \.self) { key in
                                Text("\(key)")
                                    .hAlign(.leading)
                                    .padding([.horizontal, .top], 20)
                                    .padding(.bottom, 10)
                                if let sectionPromotions = groupedPromotions[key] {
                                    ForEach(sectionPromotions) { promotionModel in
                                        PromotionPanelView(promotion: Promotion.from(promotionModel))
                                    }
                                }
                                if let sectionSessions = groupedSessions[key] {
                                    ForEach(sectionSessions, id: \.self) { session in
                                        ActivityPanelView(session: session)
                                            .onTapGesture {
                                                selectedSession = session
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    } else {
                        VStack {
                            ZStack {
                                Image("beltIcon")
                                    .resizable()
                                    .frame(maxWidth: screenWidth <= 375 ? 120 : 148, maxHeight: 148)
                                    .scaledToFit()
                                    .foregroundColor(.black)
                                Image("dotsAroundBelt")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: screenWidth <= 375 ? 250 : 282, maxHeight: 201)
                                    .offset(x: -10, y: -30)
                            }.padding(.top, 30)
                            Text("Hey! Add trainig sessions to track your BJJ progress journey!")
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                            Text("Your records will always be at hand!")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color("Gray"))
                            
                            VStack(spacing: 22) {
                                Button(action: {
                                    selectedSheet = .activity
                                    viewModel.createSessionButtonTapped()
                                }, label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(Color("Blue"))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                        Text("Create Session")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18).smallCaps())
                                            .fontWeight(.semibold)
                                    }
                                })
                                Button(action: {
                                    selectedSheet = .promotion
                                    viewModel.addPromotionButtonTapped()
                                }, label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                        Text("Add Promotion")
                                            .foregroundColor(Color("Blue"))
                                            .font(.system(size: 18).smallCaps())
                                            .fontWeight(.semibold)
                                    }
                                })
                            }
                            .padding(.top, 22)
                        }
                        .hAlign(.center)
                        .vAlign(.center)
                        .padding(.top, 30)
                        .padding(.horizontal, 30)
                        
                    }
                }
            }
            .background(Color("generalBG").ignoresSafeArea())
            .onAppear {
                settings.isTabBarHidden = true
                viewModel.onArchiveViewAppeared()
            }
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .promotion:
                    AddPromotionView(viewModel: .init())
                case .activity:
                    NewSessionView(viewModel: .init())
                }
            }
            .sheet(item: $selectedSession) { selectedSession in
                SessionDetailsView(viewModel: SessionDetailsViewModel(session: selectedSession), dismissCallback: {})
            }
            .introspectTabBarController { (UITabBarController) in
                UITabBarController.tabBar.isHidden = true
            }
            .navigationTitle("Archive")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        settings.isTabBarHidden = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color("Blue"))
                    }
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(viewModel: .init())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
            .environmentObject(AppSettings())
    }
}
