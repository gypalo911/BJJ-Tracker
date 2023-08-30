//
//  TechniquesView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct TechniquesView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isHeaderHidden = false
    @State private var isEmptySearchStateState = true
    @State private var isShowingTechniqueDetails = false
    @State private var isModifyingTechnique = false
    @State private var isEditing = false
    @State private var searchText = ""
    @State private var offsetY: CGFloat = .zero
    
//    @State private var selectedTechnique: Technique = 
    
    @FocusState private var isTextFieldFocused: Bool
    
    private var results: [String] = (0...13).map{"technique\($0)"}
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack {
                            if !isHeaderHidden {
                                HeaderView(onBack: {
                                    presentationMode.wrappedValue.dismiss()
                                }, onCreate: {
                                    isModifyingTechnique.toggle()
                                })
                                .offset(y: -offsetY)
                                .zIndex(2)
                            }
                            SearchBar(
                                isHeaderHidden: $isHeaderHidden,
                                isEditing: $isEditing,
                                searchText: $searchText,
                                isEmptySearchState: $isEmptySearchStateState
                            )
                                .offset(y: -offsetY)
                                .zIndex(1)
                            
                            if !isEmptySearchStateState {
                                SuggestionsView()
                                    .offset(y: -offsetY)
                                    .opacity(isEmptySearchStateState ? 0 : 1)
                            }
                            if !isEditing && !results.isEmpty {
                                Text("Learned techniques:")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .offset(y: -offsetY)
                                    .hAlign(.leading)
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.top, 5)
                        .padding(.horizontal, 20)
                        .background(
                            Rectangle()
                                .fill(.white)
                                .edgesIgnoringSafeArea(.all)
                                .offset(y: -offsetY)
                        )
                        .zIndex(2)
                        
                        if !isEditing && !results.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(0..<10) { item in
                                    VStack(spacing: 15) {
                                        TechbiquesListCell(onTap: {
                                            isShowingTechniqueDetails.toggle()
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .hAlign(.leading)
                        } else {
                            EmptyStateOfResults()
                                .padding(.top, isEmptySearchStateState ? 100 : 20)
                        }
                    }
                    .offset(coordinateSpace: .named("scroll")) { offset in
                        offsetY = offset
                    }
                }
                .coordinateSpace(name: "scroll")
                .background(
                    Rectangle()
                        .fill(.white)
                        .edgesIgnoringSafeArea(.all)
                )
                .onAppear {
                    settings.isTabBarHidden = true
                }
                .onDisappear {
                    settings.isTabBarHidden = false
                }
                .onChange(of: searchText) { value in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isEmptySearchStateState = value.isEmpty
                    }
                }
            }
        }
        .bottomSheet(isPresented: $isShowingTechniqueDetails) {
            TechniqueModalView(state: .overview)
        }
        .bottomSheet(isPresented: $isModifyingTechnique) {
            TechniqueModalView(state: .modifying)
        }
//        .onChange(of: settings.isTabBarHidden) { value in
//            if value == false {
//                settings.isTabBarHidden = true
//            }
//        }
    }
    
    @ViewBuilder
    func SuggestionsView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Suggestions")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(Color("GrayTextColor"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(1..<5) { tag in
                        SuggestionTagView(
                            tag: Tag(text: "tag-\(tag)"),
                            onTap: {
//                                        viewModel.add(tag: tag)
                            }
                        )
                    }
                }
                .animation(.easeInOut, value: isEditing)
                .padding(.vertical, 5)
                .padding(.horizontal, 2)
            }
        }
        .padding([.leading], 10)
    }
    
    @ViewBuilder
    func TechbiquesListCell(onTap: @escaping (() -> Void)) -> some View {
        HStack {
            HStack(alignment: .center, spacing: 4) {
                Text(.init("Delariva"))
                    .font(.footnote)
                    .fontWeight(.regular)
                    .foregroundColor(Color("Blue"))
            }
            Spacer()
            Image("chevronRight")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(Color("Blue"))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .defaultShadow()
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    @ViewBuilder
    func EmptyStateOfResults() -> some View {
        VStack(spacing: 20) {
            if !isEditing && results.isEmpty {
                Text("No techniques added yet.\nYou can create it now!")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Button(action: {
                    settings.showingCreateTechnique.toggle()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color("Green"))
                            .frame(maxWidth: 270)
                            .frame(height: 40)
                            .defaultShadow()
                        HStack {
                            Image("triangle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            Text("New Technique")
                                .font(.caption.smallCaps())
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                })
            } else {
                Image("triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                if !searchText.isEmpty {
                    Text("No results found")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                Text("You can search sessions by technique name or notes")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(Color("GrayTextColor"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

struct TechniquesView_Previews: PreviewProvider {
    static var previews: some View {
        TechniquesView()
            .environmentObject(AppSettings())
    }
}
