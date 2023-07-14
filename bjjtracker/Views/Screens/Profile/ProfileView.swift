//
//  ProfileView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 18.04.2023.
//

import SwiftUI

struct ProfileView: View {
    enum ActionSheetState {
        case none
        case gradingSystem
        case modalSheets
    }
    
    @ObservedObject var viewModel: ProfileViewViewModel
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut)
    var sessionsList: FetchedResults<Session>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut)
    var promotionModels: FetchedResults<PromotionModel>
    
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    @State var actionSheetState: ActionSheetState = .none {
        willSet {
            showingActionSheet = newValue != .none
        }
    }
    @State private var gradingSystem: GradingSystem = .adult
    
    var promotions: [Promotion] {
        promotionModels.map {
            Promotion.from($0)
        }
    }
    
    var lastPromotion: Promotion? {
        let belts = Belt.belts(for: gradingSystem)
        return promotions
            .filter {
                belts.contains($0.belt)
            }
            .sorted(by: {
                $0.belt.rawValue == $1.belt.rawValue ? ($0.stripes < $1.stripes) :
                ($0.belt.rawValue < $1.belt.rawValue)
            }).last
    }
    
    func totalTime() -> String {
        return sessionsList.map { Int($0.duration) }.reduce(0, +).minutesToDuration()
    }
    
    func isLocked(belt: Belt, lastPromotion: Promotion?) -> Bool {
        guard let lastPromotion = lastPromotion else {
            return true
        }
        return lastPromotion.belt.rawValue < belt.rawValue
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Profile")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .hAlign(.leading)
                        .background(Color.white.ignoresSafeArea())
                    
                    Button {
                        showingActionSheet = true
                        actionSheetState = .modalSheets
                    } label: {
                        Image("createButton")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("Blue"))
                    }
                    .hAlign(.trailing)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .padding(.top, 10)
                
                HStack(spacing: 10) {
                    StatsView(text: "Sessions".localizedString, value: "\(sessionsList.count)")
                    StatsView(text: "Total time".localizedString, value: totalTime())
                }.padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HStack {
                            if let lastPromotion = lastPromotion {
                                VStack(spacing: 10) {
                                    BeltView(beltColor: lastPromotion.belt.color, stripesCount: lastPromotion.stripes)
                                    Text("%@ belt %@ stripes".localized(with: ["\(lastPromotion.belt.title)", "\(Int(lastPromotion.stripes))"]))
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                }
                                .hAlign(.bottomLeading)
                            }
                            VStack {
                                Button(action: {
                                    showingActionSheet = true
                                    actionSheetState = .gradingSystem
                                }, label: {
                                    HStack(spacing: 10) {
                                        Text(gradingSystem.rawValue.localizedString.capitalized)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.black)
                                        Image(systemName: "chevron.down")
                                            .scaledToFit()
                                            .frame(width: 15)
                                            .foregroundColor(Color.black)
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 15)
                                    .background(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(lineWidth: 1)
                                            .fill(Color("LightGray"))
                                    )
                                })
                                .hAlign(.topTrailing)
                                Spacer()
                            }
                        }
                        
                        VStack {
                            HStack {
                                Text("Progress")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding([.leading, .top, .trailing], 15)
                            
                            VStack {
                                ForEach(Belt.belts(for: gradingSystem).filter { $0 != .none }, id: \.self) { belt in
                                    BeltProgressCell(
                                        belt: belt,
                                        isLocked: isLocked(belt: belt, lastPromotion: lastPromotion),
                                        promotionModels: promotionModels
                                    )
                                }
                            }
                            .padding(.horizontal, 5)
                            .padding(.bottom, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            Rectangle()
                                .fill(.white)
                                .cornerRadius(10)
                                .defaultShadow()
                        )
                    }
                    .padding([.leading, .trailing, .top], 20)
                    .padding(.bottom, 60)
                }
            }
            .actionSheet(isPresented: $showingActionSheet) {
                if actionSheetState == .gradingSystem {
                    let newSystem: GradingSystem = gradingSystem == .adult ? .junior : .adult
                    return ActionSheet(title: Text("Select Grading System"), buttons: [
                        .default(Text(newSystem.rawValue.localizedString.capitalized), action: {
                            gradingSystem = gradingSystem == .adult ? .junior : .adult
                        }),
                        .cancel()
                    ])
                } else {
                    return ActionSheet(title: Text("Select Action"), buttons: [
                        .default(Text("Add Promotion"), action: {
                            selectedSheet = .promotion
                        }),
                        .default(Text("Add Session"), action: {
                            selectedSheet = .activity
                        }),
                        .cancel()
                    ])
                }
            }
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                case .promotion:
                    AddPromotionView(viewModel: .init())
                case .activity:
                    NewSessionView(viewModel: .init())
                }
            }
            .onAppear {
                viewModel.onProfileViewAppeared()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: .init())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
