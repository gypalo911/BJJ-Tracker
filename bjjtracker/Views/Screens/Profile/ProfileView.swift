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
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.startDate)], animation: .easeInOut) var sessionsList: FetchedResults<Session>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut) var promotionModels: FetchedResults<PromotionModel>
    
    @State private var showingActionSheet: Bool = false
    @State private var selectedSheet: ModalsSheets?
    @State var actionSheetState = ActionSheetState.none {
        willSet {
            showingActionSheet = newValue != .none
        }
    }
    @State private var gradingSystem: GradingSystem = .adult
    
    func totalTime() -> String {
        return sessionsList.map { Int($0.duration) }.reduce(0, +).minutesToDuration()
    }
    
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
                ($0.belt.rawValue < $1.belt.rawValue) || ($0.stripes < $1.stripes)
            }).last
    }
    
    var beltDescription: String {
        guard let lastPromotion = lastPromotion else {
            return ""
        }
        var result = lastPromotion.belt.title
        result += " belt "
        result += "\(lastPromotion.stripes) stripes"
        return result
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
                    StatsView(text: "Sessions", value: "\(sessionsList.count)")
                    StatsView(text: "Total time", value: totalTime())
                }.padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HStack {
                            if let lastPromotion = lastPromotion {
                                VStack(spacing: 10) {
                                    BeltView(beltColor: lastPromotion.belt.color, stripesCount: Int(lastPromotion.stripes))
                                    Text(beltDescription)
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
                                        Text(gradingSystem.rawValue.capitalized)
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
                    .padding(.bottom, 40)
                }
            }
            .actionSheet(isPresented: $showingActionSheet) {
                if actionSheetState == .gradingSystem {
                    let newSystem: GradingSystem = gradingSystem == .adult ? .junior : .adult
                    return ActionSheet(title: Text("Select Grading System"), buttons: [
                        .default(Text(newSystem.rawValue.capitalized), action: {
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
                    AddPromotionView()
                case .activity:
                    NewSessionView()
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct BeltProgressCell: View {
    @State private var showPromotionsList: Bool = false
    
    private var belt: Belt
    
    private var showListBG: Bool {
        showPromotionsList && !promotionModels.isEmpty
    }
    var promotionModels: [FetchedResults<PromotionModel>.Element]
    
    private let isLocked: Bool
    
    init(belt: Belt, isLocked: Bool, promotionModels: FetchedResults<PromotionModel>) {
        self.belt = belt
        self.isLocked = isLocked
        self.promotionModels = promotionModels.filter {
            $0.belt == belt.rawValue
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            CircularBeltView(
                                primaryColor: belt.color.0,
                                secondaryColor: belt.color.1
                            )
                            if isLocked {
                                Circle()
                                    .fill(.gray.opacity(0.3))
                                    .frame(width: 36)
                                Image("lock")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(Color.black.opacity(0.6))
                            }
                        }
                        
                        Text("\(belt.title) belt")
                    }
                    Spacer()
                    if !promotionModels.isEmpty {
                        Image("info")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                    }
                }
                .padding(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if !promotionModels.isEmpty {
                            showPromotionsList.toggle()
                        }
                    }
                }
                if belt != .black {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
                if showPromotionsList {
                    BeltPromotionsList(promotionModels: promotionModels)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(showListBG ? Color("listBG") : Color.white)
        )
    }
}

struct BeltView: View {
    var beltWidth: CGFloat = 210
    var beltColor: (Color, Color?)
    var stripesCount: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(beltColor.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Gray"), lineWidth: 1)
                )
                .frame(width: beltWidth, height: 36)
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(beltColor.1 ?? .black)
                    .frame(width: 65, height: 36)
                HStack(spacing: 5) {
                    ForEach(0..<stripesCount, id: \.self) { stripe in
                        Rectangle()
                            .fill(.white)
                            .frame(width: 6)
                    }
                }
                .hAlign(.leading)
                .frame(width: 65, height: 34)
                .offset(x: 10, y: 0)
            }.offset(x: 20)
        }
    }
}

struct CircularBeltView: View {
    let primaryColor: Color
    let secondaryColor: Color?
    var isSelected: Bool = true
    var height: CGFloat = 36
    
    var strokeColor: Color {
        return isSelected ? Color.black : Color.gray
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(strokeColor, lineWidth: 2)
                )
                .frame(width: height, height: height)
            ZStack {
                Circle()
                    .trim(from: 0, to: 0.5)
                    .fill(primaryColor)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: 0.5)
                            .stroke(strokeColor, lineWidth: 2)
                    )
                    .frame(width: height - 8, height: height - 8)
            }
            .rotationEffect(.degrees(-90))
            
            if let secondaryColor = secondaryColor {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .fill(secondaryColor)
                        .overlay(
                            Circle()
                                .trim(from: 0, to: 0.5)
                                .stroke(strokeColor, lineWidth: 2)
                        )
                        .frame(width: height - 8, height: height - 8)
                }
                .rotationEffect(.degrees(90))
            }
            Rectangle()
                .fill(strokeColor)
                .frame(width: 2, height: height - 6)
        }
    }
}

struct BeltPromotionsList: View {
    var promotionModels: [FetchedResults<PromotionModel>.Element]
    
    @State var promotions: [Promotion] = []
    
    @Environment (\.managedObjectContext) var managedObjContext
    
    var body: some View {
        List {
            ForEach(promotions.prefix(5), id: \.id) { promotion in
                BeltPromotionsListCell(stripes: promotion.stripes, date: promotion.date)
                    .padding(5)
            }.onDelete { offsets in
                withAnimation(.easeInOut(duration: 0.3)) {
                    promotions.remove(atOffsets: offsets)
                    for index in offsets {
                        let model = promotionModels[index]
                        PersistanceManager.shared.delete(model: model, context: managedObjContext)
                    }
                }
            }
            .background(Color("listBG"))
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(.zero))
        }
        .listStyle(.plain)
        .frame(minHeight: 50 * CGFloat(promotions.prefix(5).count))
        .task {
            setupPromotions()
        }
    }
    
    func setupPromotions() {
        promotions = promotionModels.map {
            Promotion.from($0)
        }
    }
}

struct BeltPromotionsListCell: View {
    let stripes: Int
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Circle()
                    .foregroundColor(.black)
                    .frame(width: 10)
                Text("Stripes: \(stripes)")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
            }
            Text(date.toString("dd MMM yyyy"))
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color.gray)
                .padding(.leading, 20)
        }
        .padding(.horizontal, 20)
        .hAlign(.leading)
    }
}
