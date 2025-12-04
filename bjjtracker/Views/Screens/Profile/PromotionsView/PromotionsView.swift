//
//  PromotionsView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 02.08.2023.
//

import SwiftUI

struct PromotionsView: View {
    @Binding var isViewOpen: Bool
    @State var gradingSystem: GradingSystem
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.date)], animation: .easeInOut)
    var promotionModels: FetchedResults<PromotionModel>
    
    @State private var showingGradingActionSheet: Bool = false
    @State private var offset: CGFloat = 100
    @State private var scrollViewSize: CGSize = .zero
    
    private let defaultAnimation: Animation = Animation.easeInOut(duration: 0.25)
    
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
    
    var beltsArray: [Belt] {
        Belt.belts(for: gradingSystem).filter { $0 != .none }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.primary
                    .opacity (0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(defaultAnimation) {
                            resetStates()
                        }
                    }
                VStack {
                    VStack {
                        HStack {
                            Text("Progress")
                                .font(.body)
                                .fontWeight(.semibold)
                            Spacer()
                            
                            Button(action: {
                                showingGradingActionSheet = true
                            }, label: {
                                HStack(spacing: 10) {
                                    Text(gradingSystem.rawValue.localizedString.capitalized)
                                        .font(.footnote)
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
                        }
                        .padding([.leading, .top, .trailing], 20)
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(Array(beltsArray.enumerated()), id: \.offset) { index, belt in
                                    BeltProgressCell(
                                        belt: belt,
                                        isLocked: isLocked(belt: belt, lastPromotion: lastPromotion),
                                        promotionModels: promotionModels.map { $0 }
                                    )
                                    .id(index)
                                    .opacity(offset != 0 ? 0 : 1)
                                    .offset(x: 0.0, y: offset)
                                    .animation(defaultAnimation.delay(Double(index) * 0.1), value: offset)
                                }
                            }
                            .getSize { size in
                                withAnimation(.spring()) {
                                    scrollViewSize = size
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                        .padding(.bottom, 5)
                    }
                    .background(
                        Rectangle()
                            .fill(.white)
                            .cornerRadius(20)
                            .defaultShadow()
                            .opacity(offset != 0 ? 0 : 1)
                            .offset(x: 0.0, y: offset)
                            .animation(defaultAnimation, value: offset)
                    )
                    .frame(height: scrollViewSize.height < proxy.size.height - 200 ? scrollViewSize.height + 60 : proxy.size.height - 200)
                    .padding(.bottom, 20)
                    
                    ZStack {
                        Circle()
                            .foregroundColor(.black)
                        Image("close")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.white)
                    }
                    .frame(width: 52, height: 52)
                    .opacity(isViewOpen ? 1 : 0)
                    .onTapGesture {
                        resetStates()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 50)
                .vAlign(.bottom)
                .onAppear {
                    withAnimation(defaultAnimation) {
                        offset = 0
                    }
                }
                .actionSheet(isPresented: $showingGradingActionSheet) {
                    let newSystem: GradingSystem = gradingSystem == .adult ? .junior : .adult
                    return ActionSheet(title: Text("Select Grading System"), buttons: [
                        .default(Text(newSystem.rawValue.localizedString.capitalized), action: {
                            gradingSystem = gradingSystem == .adult ? .junior : .adult
                        }),
                        .cancel()
                    ])
                }
            }
        }
    }
    
    func resetStates() {
        withAnimation(defaultAnimation) {
            offset = 100
            isViewOpen = false
            scrollViewSize = .zero
        }
    }
    
    func isLocked(belt: Belt, lastPromotion: Promotion?) -> Bool {
        guard let lastPromotion = lastPromotion else {
            return true
        }
        return lastPromotion.belt.rawValue < belt.rawValue
    }
}

struct PromotionsView_Previews: PreviewProvider {
    struct Container: View {
        @EnvironmentObject var settings: AppSettings
        @State var gradingSystem: GradingSystem = .adult
        @State var showingPromotionsView: Bool = false
        
        var body: some View {
            NavigationView {
                GeometryReader { proxy in
                    let frame = proxy.frame(in: .global).size
                    ZStack {
                        Image("LogoWithText")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width: frame.width, height: frame.height)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showingPromotionsView = true
                                }
                            }
                    }
                }
                .ignoresSafeArea()
                .blurredPopup(isPresented: $showingPromotionsView) {
                    PromotionsView(isViewOpen: $showingPromotionsView, gradingSystem: gradingSystem)
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
            .environmentObject(AppSettings())
            .environment(\.managedObjectContext, PersistanceManager.preview.container.viewContext)
    }
}
