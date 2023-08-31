//
//  JournalView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI
import Introspect

struct JournalView: View {
    
    private let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    
    @Namespace var namespace
    
    @StateObject var viewModel: JournalViewViewModel
    
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    ScrollViewReader { proxy in
                        if !viewModel.sections.isEmpty {
                            VStack {
                                ForEach(viewModel.sections, id: \.self) { key in
                                    Text("\(key)")
                                        .hAlign(.leading)
                                        .padding([.horizontal, .top], 20)
                                        .padding(.bottom, 10)
                                    if let sectionPromotions = viewModel.groupedPromotions[key] {
                                        ForEach(sectionPromotions) { promotion in
                                            PromotionPanelView(promotion: promotion)
                                                .onTapGesture {
                                                    withAnimation(.easeInOut(duration: 0.25)) {
                                                        viewModel.selectedGradingSystem = promotion.beltType
                                                        viewModel.showingPromotionsView = true
                                                    }
                                                }
                                        }
                                    }
                                    if let sectionSessions = viewModel.groupedSessions[key] {
                                        ForEach(sectionSessions, id: \.self) { session in
                                            ActivityPanelView(session: session, namespace: namespace)
                                                .onTapGesture {
                                                    withAnimation(AppConstants.mgeAnimation) {
                                                        viewModel.selectedSession = session
                                                    }
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
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 10)
                                    .padding(.bottom, 10)
                                Text("Your records will always be at hand!")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color("Gray"))
                                
                                VStack(spacing: 22) {
                                    Button(action: {
                                        viewModel.selectedSheet = .activity
                                        viewModel.createSessionButtonTapped()
                                    }, label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundColor(Color("Blue"))
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 60)
                                                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
                                            HStack {
                                                Image("kimono")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.white)
                                                    .frame(width: 25, height: 25)
                                                Text("New Session")
                                                    .foregroundColor(.white)
                                                    .font(.body.smallCaps())
                                                    .fontWeight(.medium)
                                            }
                                        }
                                    })
                                    Button(action: {
                                        viewModel.selectedSheet = .promotion
                                        viewModel.addPromotionButtonTapped()
                                    }, label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 60)
                                                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                                            HStack {
                                                Image("beltIcon")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.black)
                                                    .frame(width: 25, height: 25)
                                                Text("New Promotion")
                                                    .foregroundColor(.black)
                                                    .font(.body.smallCaps())
                                                    .fontWeight(.medium)
                                            }
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
                .zIndex(0)
                .background(Color("generalBG").ignoresSafeArea())
                .onAppear {
                    settings.isTabBarHidden = true
                    viewModel.onJournalViewAppeared()
                    changeNavBar(.clear)
                }
                .sheet(item: $viewModel.selectedSheet) { selectedSheet in
                    switch selectedSheet {
                    case .promotion:
                        AddPromotionView(viewModel: .init())
                    case .activity:
                        NewSessionView(viewModel: .init())
                    }
                }
                .navigationTitle("Journal")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("back")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color("Blue"))
                        }
                    }
                }
                .onChange(of: viewModel.selectedSession) { _ in
                    changeNavBar(.clear)
                }
                
                if let session = viewModel.selectedSession {
                    SessionDetailsView(namespace: namespace, viewModel: SessionDetailsViewModel(session: session), dismissCallback: {
                        withAnimation(AppConstants.mgeAnimation) {
                            viewModel.selectedSession = nil
                        }
                    }).zIndex(1)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .blurredPopup(isPresented: $viewModel.showingPromotionsView) {
            PromotionsView(
                isViewOpen: $viewModel.showingPromotionsView,
                gradingSystem: viewModel.selectedGradingSystem
            )
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView(viewModel: .init(persistanceManager: PersistanceManager.preview))
            .environmentObject(AppSettings())
    }
}
