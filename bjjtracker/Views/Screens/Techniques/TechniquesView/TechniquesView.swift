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
    
    @StateObject var viewModel: TechniquesViewVM
    
    @State private var offsetY: CGFloat = .zero
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack {
                            if !viewModel.isHeaderHidden {
                                HeaderView(onBack: {
                                    presentationMode.wrappedValue.dismiss()
                                }, onCreate: {
                                    viewModel.isModifyingTechnique.toggle()
                                })
                                .offset(y: -offsetY)
                                .zIndex(2)
                            }
                            SearchBar(
                                isHeaderHidden: $viewModel.isHeaderHidden,
                                isEditing: $viewModel.isEditing,
                                searchText: $viewModel.searchText,
                                isEmptySearchState: $viewModel.isEmptySearchStateState,
                                onEndEditing: {
                                    
                                }
                            )
                            .offset(y: -offsetY)
                            .zIndex(1)
                            
                            if viewModel.isEditing && !viewModel.suggestions.isEmpty {
                                SuggestionsView()
                                    .offset(y: -offsetY)
                                    .opacity(viewModel.isEmptySearchStateState ? 0 : 1)
                            }
                            if !viewModel.isEditing && !viewModel.results.isEmpty {
                                let count = viewModel.filteredResults.count
                                if count > 0 {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Learned techniques:")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.black)
                                    }
                                    .offset(y: -offsetY)
                                    .padding(.top, 10)
                                    .hAlign(.leading)
                                }
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Rectangle()
                                .fill(.white)
                                .edgesIgnoringSafeArea(.all)
                                .offset(y: -offsetY)
                                .padding(.top, -50)
                        )
                        .zIndex(2)
                    
                        if viewModel.isEditing && viewModel.searchText.isEmpty {
                            EmptyStateOfResults()
                                .padding(.top, viewModel.isEmptySearchStateState ? 100 : 20)
                        } else if !viewModel.filteredResults.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(viewModel.filteredResults, id: \.self) { item in
                                    VStack(spacing: 15) {
                                        TechbiquesListCell(
                                            technique: item,
                                            onTap: {
                                                viewModel.selectedTechnique = item
                                                viewModel.isShowingTechniqueDetails = true
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                            .hAlign(.leading)
                        } else {
                            EmptyStateOfResults()
                                .padding(.top, viewModel.isEmptySearchStateState ? 100 : 20)
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
                    viewModel.fetchTechniques()
                }
                .onDisappear {
                    settings.isTabBarHidden = false
                }
            }
        }
        .bottomSheet(isPresented: $viewModel.isShowingTechniqueDetails) {
            if let technique = viewModel.selectedTechnique {
                TechniqueModalView(
                    showingCreateTechnique: $viewModel.isShowingTechniqueDetails,
                    state: .overview,
                    technique: technique
                    
                )
            } else {
                TechniqueModalView(
                    showingCreateTechnique: $viewModel.isShowingTechniqueDetails,
                    state: .modifying
                )
            }
        }
        .bottomSheet(isPresented: $viewModel.isModifyingTechnique) {
            TechniqueModalView(
                showingCreateTechnique: $viewModel.isModifyingTechnique,
                state: .modifying
            )
        }
        .onChange(of: viewModel.isShowingTechniqueDetails) { _ in
            settings.isTabBarHidden = true
            viewModel.fetchTechniques()
        }
        .onChange(of: viewModel.isModifyingTechnique) { _ in
            settings.isTabBarHidden = true
            viewModel.fetchTechniques()
        }
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
                    ForEach(viewModel.suggestions.indices, id: \.self) { i in
                        SuggestionTagView(
                            tag: Tag(text: viewModel.suggestions[i]),
                            onTap: {
                                viewModel.searchText = viewModel.suggestions[i]
//                                onEndEditing?()
                            }
                        )
                    }
                }
                .animation(.easeInOut, value: viewModel.isEditing)
                .padding(.vertical, 5)
                .padding(.horizontal, 2)
            }
        }
        .padding([.leading], 10)
    }
    
    @ViewBuilder
    func TechbiquesListCell(
        technique: TechniqueModel,
        onTap: @escaping (() -> Void)
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(.init(technique.text ?? ""))
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(.black)
                if let details = technique.details {
                    Text(details)
                        .font(.footnote)
                        .lineLimit(1)
                        .foregroundColor(Color("GrayTextColor"))
                }
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
            if !viewModel.isEditing && viewModel.results.isEmpty {
                Text("No techniques added yet.\nYou can create it now!")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Button(action: {
                    print("sadas ")
                    viewModel.isShowingTechniqueDetails = true
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
                if !viewModel.searchText.isEmpty {
                    Text("No results found")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                Text("You can search techniques by name or notes")
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
        TechniquesView(viewModel: .init(persistanceManager: PersistanceManager.preview))
            .environmentObject(AppSettings())
    }
}
