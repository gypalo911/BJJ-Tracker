//
//  TechniquesView.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 21.08.2023.
//

import SwiftUI

struct TechniquesView: View {
    private enum Localisation {
        static var learnedTechniques: String { "Learned techniques:".localizedString }
        static var sortSection: String { "Sort...".localizedString }
        static var sort: String { "Sort".localizedString }
        static var suggestions: String { "Suggestions".localizedString }
        static var noTechniquesAddedYet: String { "No techniques added yet.\nYou can create it now!".localizedString }
        static var newTechnique: String { "New Technique".localizedString }
        static var noResultsFound: String { "No results found".localizedString }
        static var searchHelp: String { "You can search techniques by name or notes".localizedString }
    }

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
                                HStack(alignment: .center) {
                                    let count = viewModel.filteredResults.count
                                    if count > 0 {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(Localisation.learnedTechniques)
                                                .font(token: DesignSystem.shared.fonts.body, weight: .semibold)
                                                .foregroundColor(.black)
                                        }
                                        .hAlign(.leading)
                                        
                                        Menu {
                                            Section(Localisation.sortSection) {
                                                Picker(Localisation.sort, selection: $viewModel.sortingType) {
                                                    ForEach(SortingType.allCases) {
                                                        Text($0.title)
                                                            .tag($0)
                                                    }
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "arrow.up.arrow.down")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .offset(y: -offsetY)
                                .padding(.top, 10)
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
            .toolbar(.hidden, for: .navigationBar)
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
        .onChange(of: viewModel.isShowingTechniqueDetails) {
            settings.isTabBarHidden = true
            viewModel.fetchTechniques()
        }
        .onChange(of: viewModel.isModifyingTechnique) {
            settings.isTabBarHidden = true
            viewModel.fetchTechniques()
        }
    }
    
    @ViewBuilder
    func SuggestionsView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(Localisation.suggestions)
                .font(token: DesignSystem.shared.fonts.footnote, weight: .semibold)
                .foregroundColor(DesignSystem.shared.colors.grayText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.suggestions.indices, id: \.self) { i in
                        SuggestionTagView(
                            tag: Tag(text: viewModel.suggestions[i]),
                            onTap: {
                                viewModel.searchText = viewModel.suggestions[i]
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
                    .font(token: DesignSystem.shared.fonts.body, weight: .regular)
                    .foregroundColor(.black)
                if let details = technique.details {
                    Text(details)
                        .font(token: DesignSystem.shared.fonts.footnote)
                        .lineLimit(1)
                        .foregroundColor(DesignSystem.shared.colors.grayText)
                }
            }
            Spacer()
            Image("chevronRight")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(DesignSystem.shared.colors.blue)
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
                Text(Localisation.noTechniquesAddedYet)
                    .font(token: DesignSystem.shared.fonts.footnote, weight: .medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                Button(action: {
                    viewModel.isShowingTechniqueDetails = true
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(DesignSystem.shared.colors.green)
                            .frame(maxWidth: 270)
                            .frame(height: 40)
                            .defaultShadow()
                        HStack {
                            Image("triangle")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            Text(Localisation.newTechnique)
                                .font(buttons: .small, weight: .medium)
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
                    Text(Localisation.noResultsFound)
                        .font(token: DesignSystem.shared.fonts.title2, weight: .bold)
                        .foregroundColor(.black)
                }
                Text(Localisation.searchHelp)
                    .font(token: DesignSystem.shared.fonts.footnote, weight: .medium)
                    .foregroundColor(DesignSystem.shared.colors.grayText)
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
